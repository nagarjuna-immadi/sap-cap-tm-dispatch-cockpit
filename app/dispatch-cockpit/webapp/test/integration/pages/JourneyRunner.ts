import JourneyRunner from "sap/fe/test/JourneyRunner";
import ListReport from "sap/fe/test/ListReport";
import ObjectPage from "sap/fe/test/ObjectPage";
import CustomFreightOrdersListGenerated from "./FreightOrdersList.gen";
import CustomFreightOrdersObjectPageGenerated from "./FreightOrdersObjectPage.gen";

const runner = new JourneyRunner({
    launchUrl: sap.ui.require.toUrl("tm/dispatch/dispatchcockpit") + "/test/flp.html#app-preview",
    pages: {
        onTheFreightOrdersListGenerated: new ListReport(
            {
                appId: "tm.dispatch.dispatchcockpit",
                componentId: "FreightOrdersList",
                entitySet: "",
                contextPath: "/FreightOrders"
            },
            CustomFreightOrdersListGenerated
        ),
        onTheFreightOrdersObjectPageGenerated: new ObjectPage(
            {
                appId: "tm.dispatch.dispatchcockpit",
                componentId: "FreightOrdersObjectPage",
                entitySet: "",
                contextPath: "/FreightOrders"
            },
            CustomFreightOrdersObjectPageGenerated
        )
    },
    async: true
});

export default runner;
