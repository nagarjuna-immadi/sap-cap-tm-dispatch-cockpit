import ExtensionAPI from "sap/fe/templates/ObjectPage/ExtensionAPI";
import Context from "sap/ui/model/odata/v4/Context";
import MessageToast from "sap/m/MessageToast";
import ResourceModel from "sap/ui/model/resource/ResourceModel";
import ResourceBundle from "sap/base/i18n/ResourceBundle";

/**
 * "Open Tender" on the freight order page: navigates to the order's dispatch, where
 * the tender rounds, offers, exceptions and notes are. Dispatch is a top-level route
 * (see manifest.json) because the freight order is remote and not draft-enabled.
 * Reading the freight order has already created its dispatch.
 */
export async function open(this: ExtensionAPI, context: Context): Promise<void> {
	const id = (await context.requestProperty("dispatch/ID")) as string | undefined;
	if (!id) {
		const bundle = (this.getModel("i18n") as ResourceModel).getResourceBundle() as ResourceBundle;
		MessageToast.show(bundle.getText("noDispatch") ?? "");
		return;
	}
	await this.getRouting().navigateToRoute("DispatchObjectPage", { key: `ID=${id},IsActiveEntity=true` });
}
