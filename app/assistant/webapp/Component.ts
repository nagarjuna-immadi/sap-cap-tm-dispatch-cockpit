import UIComponent from "sap/ui/core/UIComponent";

// marked (vendored, UMD) is not a UI5 module: load it through its global export.
sap.ui.loader.config({
	shim: {
		"tm/dispatch/assistant/thirdparty/marked": { amd: false, deps: [], exports: "marked" }
	}
});

/**
 * @namespace tm.dispatch.assistant
 */
export default class Component extends UIComponent {
	public static metadata = {
		manifest: "json",
		interfaces: ["sap.ui.core.IAsyncContentCreation"]
	};

	/**
	 * Absolute URL of an agent's A2A endpoint. The manifest's data source URIs are
	 * relative (a2a/...), so they resolve under the Work Zone approuter as well as under
	 * /tm.dispatch.assistant/ locally (see server.js).
	 */
	public getAgentUrl(dataSource: string): string {
		const manifest = this.getManifestObject();
		const sources = manifest.getEntry("/sap.app/dataSources") as Record<string, { uri: string }>;
		return manifest.resolveUri(sources[dataSource].uri);
	}
}
