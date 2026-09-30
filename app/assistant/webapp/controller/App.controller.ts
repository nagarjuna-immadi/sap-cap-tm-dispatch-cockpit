import Controller from "sap/ui/core/mvc/Controller";
import JSONModel from "sap/ui/model/json/JSONModel";
import ResourceModel from "sap/ui/model/resource/ResourceModel";
import ResourceBundle from "sap/base/i18n/ResourceBundle";
import Log from "sap/base/Log";
import HTML from "sap/ui/core/HTML";
import Control from "sap/ui/core/Control";
import VBox from "sap/m/VBox";
import HBox from "sap/m/HBox";
import Text from "sap/m/Text";
import Title from "sap/m/Title";
import Button from "sap/m/Button";
import ObjectAttribute from "sap/m/ObjectAttribute";
import ObjectStatus from "sap/m/ObjectStatus";
import MessageStrip from "sap/m/MessageStrip";
import ScrollContainer from "sap/m/ScrollContainer";
import TextArea from "sap/m/TextArea";
import { SegmentedButton$SelectionChangeEvent } from "sap/m/SegmentedButton";
import { ButtonType, FlexJustifyContent, FlexRendertype, FlexWrap } from "sap/m/library";
import { MessageType, TitleLevel, ValueState } from "sap/ui/core/library";
import type Component from "../Component";
import A2AClient, { AgentCard, Approval, TurnHandlers, TurnResult } from "../model/a2a";
import Markdown from "../model/markdown";

interface Bubble {
	stepId: string;
	box: VBox;
	html: HTML;
	text: string;
}

interface Conversation {
	key: string;
	title: string;
	card: AgentCard;
	client: A2AClient;
	/** holds the messages of this agent; only the selected agent's box is visible */
	box: VBox;
	welcome?: Control;
	pending?: Approval;
	/** the model turn that is streaming right now */
	live?: Bubble;
}

/**
 * @namespace tm.dispatch.assistant.controller
 */
export default class App extends Controller {
	/** The agents TM Assistant knows; each is shown only if the user may read its card. */
	private static readonly AGENTS = [
		{ key: "dispatch", dataSource: "dispatchAgent", titleKey: "agentDispatch" },
		{ key: "tender", dataSource: "tenderAgent", titleKey: "agentTender" }
	];
	/** The langchain default description repeats the arguments; the card lists them itself. */
	private static readonly DEFAULT_HITL_DESCRIPTION = /^Tool execution requires approval/;
	private static readonly MAX_SUGGESTIONS = 6;

	private model: JSONModel;
	private bundle: ResourceBundle;
	private conversations = new Map<string, Conversation>();
	private current?: Conversation;

	public onInit(): void {
		this.model = new JSONModel({
			loading: true,
			agents: [],
			agentKey: "",
			agentName: "",
			noAgentText: "",
			placeholder: "",
			input: "",
			busy: false,
			busyText: "",
			pending: false
		});
		this.getView()!.setModel(this.model, "chat");

		// Enter sends, Shift+Enter adds a line
		this.byId("input")!.addEventDelegate({
			onkeydown: (event: KeyboardEvent) => {
				if (event.key === "Enter" && !event.shiftKey && !event.isComposing) {
					event.preventDefault();
					this.sendInput();
				}
			}
		});
		void this.start();
	}

	private async start(): Promise<void> {
		const component = this.getOwnerComponent() as Component;
		this.bundle = await (component.getModel("i18n") as ResourceModel).getResourceBundle();
		this.model.setProperty("/agentName", this.text("appTitle"));
		await this.loadAgents(component);
	}

	/** Reads every agent's card; a 401/403 hides the agent (the user lacks its role). */
	private async loadAgents(component: Component): Promise<void> {
		const loaded = await Promise.all(
			App.AGENTS.map(async agent => {
				const client = new A2AClient(component.getAgentUrl(agent.dataSource));
				try {
					const card = await client.loadCard();
					return card ? { ...agent, client, card } : undefined;
				} catch (error) {
					Log.error(`Agent card of ${agent.key} could not be read`, String(error), "tm.dispatch.assistant");
					return undefined;
				}
			})
		);
		const container = this.byId("conversations") as VBox;
		for (const agent of loaded) {
			if (!agent) {continue;}
			const box = new VBox({ visible: false, width: "100%" }).addStyleClass("tmaConversation");
			container.addItem(box);
			const conversation: Conversation = { key: agent.key, title: this.text(agent.titleKey), card: agent.card, client: agent.client, box };
			this.conversations.set(agent.key, conversation);
			this.showWelcome(conversation);
		}
		this.model.setProperty(
			"/agents",
			[...this.conversations.values()].map(({ key, title }) => ({ key, title }))
		);
		this.model.setProperty("/noAgentText", this.text("noAgentText"));
		this.model.setProperty("/loading", false);
		const first = this.conversations.keys().next();
		if (!first.done) {this.selectAgent(first.value);}
	}

	public onAgentChange(event: SegmentedButton$SelectionChangeEvent): void {
		const key = event.getParameter("item")?.getKey();
		if (key) {this.selectAgent(key);}
	}

	private selectAgent(key: string): void {
		const conversation = this.conversations.get(key);
		if (!conversation) {return;}
		this.current = conversation;
		for (const other of this.conversations.values()) {other.box.setVisible(other === conversation);}
		this.model.setProperty("/agentKey", key);
		this.model.setProperty("/agentName", conversation.card.name || conversation.title);
		this.model.setProperty("/placeholder", this.text("inputPlaceholder", [conversation.title]));
		this.model.setProperty("/pending", !!conversation.pending);
		this.scrollToBottom();
	}

	public onNewConversation(): void {
		const conversation = this.current;
		if (!conversation) {return;}
		conversation.client.resetConversation();
		conversation.box.destroyItems();
		conversation.pending = undefined;
		conversation.live = undefined;
		this.model.setProperty("/pending", false);
		this.showWelcome(conversation);
		(this.byId("input") as TextArea).focus();
	}

	public onSendPress(): void {
		if (this.model.getProperty("/busy")) {
			this.current?.client.cancel();
		} else {
			this.sendInput();
		}
	}

	private sendInput(): void {
		const text = (this.model.getProperty("/input") as string).trim();
		if (!text || this.model.getProperty("/busy") || this.model.getProperty("/pending")) {return;}
		this.model.setProperty("/input", "");
		this.send(text);
	}

	private send(text: string): void {
		const conversation = this.current;
		if (!conversation) {return;}
		conversation.welcome?.destroy();
		conversation.welcome = undefined;
		conversation.box.addItem(new HBox({
				// Bare: the bubble is the flex item itself, so its max-width is relative to the chat width
				renderType: FlexRendertype.Bare,
				justifyContent: FlexJustifyContent.End,
				items: [new Text({ text }).addStyleClass("tmaBubble tmaUser")]
			}));
		void this.runTurn(conversation, handlers => conversation.client.send(text, handlers));
	}

	/** Runs one agent turn (a message or an approval decision) and renders its outcome. */
	private async runTurn(conversation: Conversation, call: (handlers: TurnHandlers) => Promise<TurnResult>): Promise<void> {
		this.model.setProperty("/busy", true);
		this.model.setProperty("/busyText", this.text("thinking"));
		this.scrollToBottom();
		const handlers: TurnHandlers = {
			onStatus: text => this.model.setProperty("/busyText", text),
			onStep: (stepId, text) => this.showStep(conversation, stepId, text)
		};
		try {
			this.showResult(conversation, await call(handlers));
		} catch (error) {
			this.addError(conversation, this.text("failed", [(error as Error).message || String(error)]));
		} finally {
			conversation.live = undefined;
			this.model.setProperty("/busy", false);
			this.model.setProperty("/busyText", "");
			this.scrollToBottom();
		}
	}

	/**
	 * Streams a model turn into a bubble. Every turn streams as a "thinking" step; when a
	 * new turn starts, the previous one was an intermediate step (before a tool call) and
	 * is shown muted. The final answer is the last turn.
	 */
	private showStep(conversation: Conversation, stepId: string, text: string): void {
		let live = conversation.live;
		if (live?.stepId !== stepId) {
			live?.box.addStyleClass("tmaStep");
			live = conversation.live = this.addAgentBubble(conversation, text, stepId);
		}
		live.text = text;
		live.html.setContent(Markdown.toHtml(text));
		this.scrollToBottom();
	}

	private showResult(conversation: Conversation, result: TurnResult): void {
		const live = conversation.live;
		switch (result.state) {
			case "completed": {
				const answer = result.answer?.trim();
				if (answer && live?.text.trim() !== answer) {
					live?.box.addStyleClass("tmaStep");
					this.addAgentBubble(conversation, answer);
				} else if (!answer && !live) {
					this.addInfo(conversation, this.text("noAnswer"));
				}
				break;
			}
			case "input-required":
				if (result.approval) {this.addApproval(conversation, result.approval);}
				break;
			case "canceled":
				this.addInfo(conversation, this.text("canceled"));
				break;
			default:
				this.addError(conversation, this.text("failed", [result.error ?? result.state]));
		}
	}

	private addAgentBubble(conversation: Conversation, text: string, stepId = ""): Bubble {
		const html = new HTML({ content: Markdown.toHtml(text), sanitizeContent: true, preferDOM: false });
		const box = new VBox({ items: [html] }).addStyleClass("tmaBubble tmaAgent");
		conversation.box.addItem(box);
		return { stepId, box, html, text };
	}

	/** The approval card: action, parameters and one button per option (Approve / Reject). */
	private addApproval(conversation: Conversation, approval: Approval): void {
		conversation.pending = approval;
		if (conversation === this.current) {this.model.setProperty("/pending", true);}

		const description =
			approval.kind === "hitl" && (!approval.description || App.DEFAULT_HITL_DESCRIPTION.test(approval.description))
				? this.text("approvalText")
				: approval.description;
		const card = new VBox().addStyleClass("tmaApproval");
		card.addItem(
			new Title({
				text: approval.name ? this.text("approvalTitle", [approval.name]) : this.text("approve"),
				level: TitleLevel.H5,
				wrapping: true
			})
		);
		card.addItem(new Text({ text: description }).addStyleClass("sapUiTinyMarginTopBottom"));
		for (const [name, value] of Object.entries(approval.args ?? {})) {
			card.addItem(new ObjectAttribute({ title: name, text: this.formatValue(value) }));
		}

		const options = approval.options.length
			? approval.options
			: [
					{ value: "approve", label: this.text("approve") },
					{ value: "reject", label: this.text("reject") }
				];
		const buttons = new HBox({ wrap: FlexWrap.Wrap }).addStyleClass("sapUiSmallMarginTop");
		for (const option of options) {
			const isReject = option.value === "reject";
			buttons.addItem(
				new Button({
					text: option.label,
					type: isReject ? ButtonType.Reject : ButtonType.Accept,
					icon: isReject ? "sap-icon://decline" : "sap-icon://accept",
					press: () => this.decide(conversation, approval, option.value, option.label, buttons)
				}).addStyleClass("sapUiTinyMarginEnd")
			);
		}
		card.addItem(buttons);
		conversation.box.addItem(card);
	}

	private decide(conversation: Conversation, approval: Approval, value: string, label: string, buttons: HBox): void {
		if (conversation.pending !== approval || this.model.getProperty("/busy")) {return;}
		conversation.pending = undefined;
		this.model.setProperty("/pending", false);

		const isReject = value === "reject";
		const card = buttons.getParent() as VBox;
		buttons.destroy();
		card.addItem(
			new ObjectStatus({
				text: approval.name ? this.text(isReject ? "rejected" : "approved", [approval.name]) : label,
				state: isReject ? ValueState.Error : ValueState.Success,
				icon: isReject ? "sap-icon://decline" : "sap-icon://accept"
			}).addStyleClass("sapUiTinyMarginTop")
		);
		void this.runTurn(conversation, handlers => conversation.client.decide(approval, value, this.text("rejectReason"), handlers));
	}

	/** Empty conversation: the agent's description and the examples of its skills as suggestions. */
	private showWelcome(conversation: Conversation): void {
		const { card } = conversation;
		const welcome = new VBox().addStyleClass("tmaWelcome");
		if (card.description) {welcome.addItem(new Text({ text: card.description }));}
		const examples = (card.skills ?? []).flatMap(skill => skill.examples ?? []).slice(0, App.MAX_SUGGESTIONS);
		if (examples.length) {
			welcome.addItem(new Title({ text: this.text("suggestions"), level: TitleLevel.H6 }).addStyleClass("sapUiSmallMarginTop"));
			const list = new HBox({ wrap: FlexWrap.Wrap });
			for (const example of examples) {
				list.addItem(
					new Button({
						text: example,
						type: ButtonType.Ghost,
						press: () => {
							if (!this.model.getProperty("/busy") && !conversation.pending) {this.send(example);}
						}
					}).addStyleClass("sapUiTinyMarginEnd sapUiTinyMarginTop tmaSuggestion")
				);
			}
			welcome.addItem(list);
		}
		conversation.welcome = welcome;
		conversation.box.addItem(welcome);
	}

	private addInfo(conversation: Conversation, text: string): void {
		conversation.box.addItem(new Text({ text }).addStyleClass("tmaInfo"));
	}

	private addError(conversation: Conversation, text: string): void {
		conversation.box.addItem(new MessageStrip({ text, type: MessageType.Error, showIcon: true }).addStyleClass("tmaBubble"));
	}

	private formatValue(value: unknown): string {
		if (Array.isArray(value)) {return value.map(item => this.formatValue(item)).join(", ");}
		if (value && typeof value === "object") {return JSON.stringify(value);}
		return typeof value === "string" || typeof value === "number" || typeof value === "boolean" ? String(value) : "";
	}

	private scrollToBottom(): void {
		const scroller = this.byId("scroller") as ScrollContainer;
		setTimeout(() => {
			const dom = scroller.getDomRef();
			if (dom) {scroller.scrollTo(0, dom.scrollHeight, 0);}
		}, 0);
	}

	private text(key: string, args?: unknown[]): string {
		return this.bundle?.getText(key, args) ?? key;
	}
}
