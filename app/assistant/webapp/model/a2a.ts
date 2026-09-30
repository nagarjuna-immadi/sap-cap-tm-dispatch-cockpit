/**
 * Minimal A2A client for the CAP agents (`@cap-js/agents`) at /a2a/<service>/.
 *
 * - JSON-RPC `message/stream` (SSE) when the agent card advertises streaming, with a
 *   fallback to `message/send` when the server does not support it.
 * - Keeps the `contextId` of the conversation, so follow-up messages continue it.
 * - A task that pauses for approval (`input-required`) is returned as an `Approval`;
 *   `decide()` resumes it with the user's decision.
 * - Fetches the CSRF token with the agent card, as the approuter route has
 *   `csrfProtection: true` (locally CAP sends none, and none is needed).
 */

export interface AgentSkill {
	id: string;
	name: string;
	description?: string;
	examples?: string[];
}

export interface AgentCard {
	name: string;
	description?: string;
	capabilities?: { streaming?: boolean };
	skills?: AgentSkill[];
}

export interface ApprovalOption {
	value: string;
	label: string;
}

export interface Approval {
	taskId: string;
	/** `hitl`: a tool call waits for approval; `timeout`: the task ran long and asks to continue */
	kind: "hitl" | "timeout";
	name?: string;
	args?: Record<string, unknown>;
	description: string;
	options: ApprovalOption[];
}

export interface TurnHandlers {
	/** Progress text of the running task (tool calls and the like) */
	onStatus?(text: string): void;
	/** A streamed model turn, with its full text so far; `stepId` changes with each turn */
	onStep?(stepId: string, text: string): void;
}

export interface TurnResult {
	/** completed, input-required, failed, canceled or rejected */
	state: string;
	answer?: string;
	approval?: Approval;
	error?: string;
}

type Part = { kind: string; text?: string; data?: Record<string, unknown> };
type Message = { role?: string; parts?: Part[]; metadata?: Record<string, unknown> };
type Status = { state: string; message?: Message };
type Artifact = { artifactId?: string; parts?: Part[] };
type TaskLike = { id?: string; taskId?: string; contextId?: string; status?: Status; artifacts?: Artifact[] };
type StreamEvent = TaskLike & {
	kind: string;
	final?: boolean;
	append?: boolean;
	lastChunk?: boolean;
	artifact?: Artifact;
};
type RpcEnvelope<T> = { result?: T; error?: { code: number; message: string } };
type ActionRequest = { name?: string; args?: Record<string, unknown>; description?: string };
type PendingHitl = { decisions?: unknown[]; actionRequests?: ActionRequest[] };

export class A2AError extends Error {
	constructor(message: string, public readonly status?: number) {
		super(message);
	}
}

export default class A2AClient {
	private static readonly HITL_KEY = "sap.cds.agents.hitl";
	private static readonly TIMEOUT_HITL_KEY = "sap.cds.agents.timeout-hitl";
	private static readonly INPUT_REQUIRED_KEY = "sap.cds.agents.input-required";
	/** JSON-RPC codes meaning "streaming is not available here": method not found, unsupported operation */
	private static readonly NO_STREAMING_CODES = [-32601, -32004];

	readonly url: string;
	private card?: AgentCard;
	private streaming = false;
	private contextId?: string;
	private csrfToken?: string;
	private activeTaskId?: string;
	private abortController?: AbortController;

	/** @param url the agent's A2A endpoint, ending with a slash (e.g. `.../a2a/dispatch-agent/`) */
	constructor(url: string) {
		this.url = url.endsWith("/") ? url : url + "/";
	}

	/** Reads the agent card. Returns `undefined` when the user may not use the agent (401/403/404). */
	async loadCard(): Promise<AgentCard | undefined> {
		const response = await fetch(this.url + ".well-known/agent-card.json", {
			headers: { Accept: "application/json", "X-CSRF-Token": "Fetch" },
			credentials: "same-origin"
		});
		if ([401, 403, 404].includes(response.status)) {return undefined;}
		if (!response.ok) {throw new A2AError(`${response.status} ${response.statusText}`, response.status);}
		this.rememberCsrfToken(response);
		this.card = (await response.json()) as AgentCard;
		this.streaming = !!this.card.capabilities?.streaming;
		return this.card;
	}

	/** Forgets the conversation; the next message starts a new one. */
	resetConversation(): void {
		this.contextId = undefined;
		this.activeTaskId = undefined;
	}

	/** Sends a user message and runs the task until it completes, fails or pauses for approval. */
	send(text: string, handlers: TurnHandlers = {}): Promise<TurnResult> {
		return this.run({ parts: [{ kind: "text", text }] }, handlers);
	}

	/**
	 * Resumes a paused task with the user's decision (an option value of the approval).
	 * An approval of a tool call is sent as a structured decision; a timeout question as text.
	 */
	decide(approval: Approval, value: string, rejectMessage: string, handlers: TurnHandlers = {}): Promise<TurnResult> {
		const parts: Part[] =
			approval.kind === "hitl"
				? [
						{
							kind: "data",
							data: { decisions: [value === "reject" ? { type: "reject", message: rejectMessage } : { type: "approve" }] }
						}
					]
				: [{ kind: "text", text: value }];
		return this.run({ parts, taskId: approval.taskId }, handlers);
	}

	/** Stops the running request and asks the server to cancel its task. */
	cancel(): void {
		const taskId = this.activeTaskId;
		this.abortController?.abort();
		if (taskId) {
			this.post("tasks/cancel", { id: taskId }).catch(() => undefined);
		}
	}

	private async run(message: { parts: Part[]; taskId?: string }, handlers: TurnHandlers): Promise<TurnResult> {
		const params = {
			message: {
				role: "user",
				messageId: crypto.randomUUID(),
				...(this.contextId ? { contextId: this.contextId } : {}),
				...message
			}
		};
		this.abortController = new AbortController();
		try {
			if (this.streaming) {
				const streamed = await this.stream(params, handlers);
				if (streamed) {return streamed;}
				this.streaming = false; // the server has no streaming: use message/send from now on
			}
			const response = await this.post("message/send", params);
			const envelope = (await this.readJson(response)) as RpcEnvelope<TaskLike>;
			if (envelope.error) {throw new A2AError(envelope.error.message);}
			return this.toResult(envelope.result ?? {});
		} catch (error) {
			if ((error as Error).name === "AbortError") {return { state: "canceled" };}
			throw error;
		} finally {
			this.abortController = undefined;
			this.activeTaskId = undefined;
		}
	}

	/** Runs `message/stream`. Returns `undefined` when the server does not support streaming. */
	private async stream(params: object, handlers: TurnHandlers): Promise<TurnResult | undefined> {
		const response = await this.post("message/stream", params, "text/event-stream");
		if (!(response.headers.get("content-type") ?? "").includes("text/event-stream")) {
			const envelope = (await this.readJson(response)) as RpcEnvelope<unknown>;
			if (envelope.error && A2AClient.NO_STREAMING_CODES.includes(envelope.error.code)) {return undefined;}
			throw new A2AError(envelope.error?.message ?? `Unexpected response (${response.status})`);
		}
		if (!response.body) {return undefined;}

		const steps = new Map<string, string>();
		let answer: string | undefined;
		let last: TaskLike | undefined;

		const onEvent = (event: StreamEvent): void => {
			if (event.contextId) {this.contextId = event.contextId;}
			if (event.kind === "task" && event.id) {this.activeTaskId = event.id;}
			if (event.taskId) {this.activeTaskId = event.taskId;}

			if (event.kind === "artifact-update") {
				const id = event.artifact?.artifactId ?? "";
				const text = A2AClient.partsToText(event.artifact?.parts);
				if (id === "response") {
					if (event.lastChunk || !event.append) {answer = text;}
					else {answer = (answer ?? "") + text;}
				} else if (id.startsWith("thinking") && text) {
					const full = (event.append ? steps.get(id) ?? "" : "") + text;
					steps.set(id, full);
					handlers.onStep?.(id, full);
				}
				return;
			}
			if (event.kind === "status-update") {
				if (event.final) {
					last = { id: event.taskId, contextId: event.contextId, status: event.status };
				} else {
					const text = A2AClient.partsToText(event.status?.message?.parts);
					if (text) {handlers.onStatus?.(text);}
				}
				return;
			}
			if (event.kind === "task") {last = event;} // a task that was already final when the stream started
		};

		await this.readEvents(response.body, onEvent);
		const result = this.toResult(last ?? { status: { state: "completed" } });
		if (answer !== undefined && result.state === "completed") {result.answer = answer;}
		return result;
	}

	/** Reads the SSE stream; each `data:` line is a JSON-RPC envelope around one event. */
	private async readEvents(body: ReadableStream<Uint8Array>, onEvent: (event: StreamEvent) => void): Promise<void> {
		const reader = body.getReader();
		const decoder = new TextDecoder();
		let buffer = "";
		const handleLine = (raw: string): void => {
			const line = raw.trim();
			if (!line.startsWith("data:")) {return;}
			let envelope: RpcEnvelope<StreamEvent>;
			try {
				envelope = JSON.parse(line.slice(5).trim()) as RpcEnvelope<StreamEvent>;
			} catch {
				return; // keep-alive or partial noise
			}
			if (envelope.error) {throw new A2AError(envelope.error.message);}
			if (envelope.result) {onEvent(envelope.result);}
		};
		for (;;) {
			const { done, value } = await reader.read();
			if (done) {break;}
			buffer += decoder.decode(value, { stream: true });
			let end: number;
			while ((end = buffer.indexOf("\n")) !== -1) {
				handleLine(buffer.slice(0, end));
				buffer = buffer.slice(end + 1);
			}
		}
		handleLine(buffer + decoder.decode());
	}

	/** Maps a final task (from `message/send` or the last stream event) to a turn result. */
	private toResult(task: TaskLike): TurnResult {
		if (task.contextId) {this.contextId = task.contextId;}
		const state = task.status?.state ?? "completed";
		const message = task.status?.message;
		const taskId = task.id ?? task.taskId ?? "";

		if (state === "input-required") {
			return { state, approval: this.toApproval(taskId, message) };
		}
		if (state === "completed") {
			const response = task.artifacts?.find(artifact => artifact.artifactId === "response") ?? task.artifacts?.[0];
			return { state, answer: A2AClient.partsToText(response?.parts) || A2AClient.partsToText(message?.parts) || undefined };
		}
		return { state, error: A2AClient.partsToText(message?.parts) || undefined };
	}

	private toApproval(taskId: string, message?: Message): Approval {
		const metadata = message?.metadata ?? {};
		const options = (metadata[A2AClient.INPUT_REQUIRED_KEY] as { options?: ApprovalOption[] } | undefined)?.options ?? [];
		const text = A2AClient.partsToText(message?.parts);
		if (metadata[A2AClient.TIMEOUT_HITL_KEY] === true) {
			return { taskId, kind: "timeout", description: text, options };
		}
		// With several tool calls in one turn, the server asks for one decision at a time.
		const pending = metadata[A2AClient.HITL_KEY] as PendingHitl | undefined;
		const requests =
			pending?.actionRequests ?? ((A2AClient.dataPart(message?.parts)?.actionRequests as ActionRequest[] | undefined) ?? []);
		const action = requests[pending?.decisions?.length ?? 0] ?? requests[0];
		return {
			taskId,
			kind: "hitl",
			name: action?.name,
			args: action?.args,
			description: action?.description ?? text,
			options
		};
	}

	private static partsToText(parts?: Part[]): string {
		return (parts ?? [])
			.filter(part => typeof part.text === "string")
			.map(part => part.text)
			.join("");
	}

	private static dataPart(parts?: Part[]): Record<string, unknown> | undefined {
		return parts?.find(part => part.kind === "data")?.data;
	}

	private async post(method: string, params: object, accept = "application/json", retried = false): Promise<Response> {
		const headers: Record<string, string> = { "Content-Type": "application/json", Accept: accept };
		if (this.csrfToken) {headers["X-CSRF-Token"] = this.csrfToken;}
		const response = await fetch(this.url, {
			method: "POST",
			headers,
			credentials: "same-origin",
			signal: this.abortController?.signal,
			body: JSON.stringify({ jsonrpc: "2.0", id: crypto.randomUUID(), method, params })
		});
		if (response.status === 403 && response.headers.get("x-csrf-token")?.toLowerCase() === "required" && !retried) {
			await this.fetchCsrfToken();
			return this.post(method, params, accept, true);
		}
		if (response.status === 401 || response.status === 403) {
			throw new A2AError(`${response.status} ${response.statusText}`, response.status);
		}
		return response;
	}

	private async readJson(response: Response): Promise<unknown> {
		const type = response.headers.get("content-type") ?? "";
		if (!type.includes("json")) {
			// e.g. the approuter's login page after the session expired
			throw new A2AError(`${response.status} ${response.statusText || "Unexpected response"}`, response.status);
		}
		return response.json();
	}

	private async fetchCsrfToken(): Promise<void> {
		const response = await fetch(this.url + ".well-known/agent-card.json", {
			method: "HEAD",
			headers: { "X-CSRF-Token": "Fetch" },
			credentials: "same-origin"
		});
		this.rememberCsrfToken(response);
	}

	private rememberCsrfToken(response: Response): void {
		const token = response.headers.get("x-csrf-token");
		if (token && token.toLowerCase() !== "required") {this.csrfToken = token;}
	}
}
