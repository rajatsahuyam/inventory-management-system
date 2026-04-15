sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/core/routing/History"
], function (ControllerExtension, History) {
    "use strict";

    return ControllerExtension.extend("inventorymanagementsystem.ext.controller.ObjectPageExt", {

        override: {
            onInit: function () {
            }
        },
        onProductBackPress: function () {
            const oHistory = sap.ui.core.routing.History.getInstance();
            const sPreviousHash = oHistory.getPreviousHash();
            if (sPreviousHash) {
                window.history.go(-1);
            } else {
                this.base.getExtensionAPI()
                    .getRouting()
                    .navigateToRoute("ProductsList")
            }
        },

        onOrderBackPress: function () {
            const oHistory = sap.ui.core.routing.History.getInstance();
            const sPreviousHash = oHistory.getPreviousHash();
            if (sPreviousHash) {
                window.history.go(-1);
            } else {
                this.base.getExtensionAPI()
                    .getRouting()
                    .navigateToRoute("OrdersList")
            }
        },

        onCustomerBackPress: function () {
            const oHistory = sap.ui.core.routing.History.getInstance();
            const sPreviousHash = oHistory.getPreviousHash();
            if (sPreviousHash) {
                window.history.go(-1);
            } else {
                this.base.getExtensionAPI()
                    .getRouting()
                    .navigateToRoute("CustomersList")
            }
        }
    });
});