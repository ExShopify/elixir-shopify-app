/*
Handles the integration between flash to a Shopify AppBridge Toast

See ShopAdminComponents.toast
*/
export const ShopifyToastHook = {
  mounted() {
    shopify.toast.show(this.el.dataset.message, {
      onDismiss: () => {
        this.pushEvent("lv:clear-flash", {
          value: { key: this.el.dataset.kind },
        });
      },
      isError: this.el.dataset.kind == "error",
    });
  },
  updated() {
    shopify.toast.show(this.el.dataset.message, {
      onDismiss: () => {
        this.pushEvent("lv:clear-flash", {
          value: { key: this.el.dataset.kind },
        });
      },
      isError: this.el.dataset.kind == "error",
    });
  },
};

export const ShopifyUserToken = {
  mounted() {
    _this = this;
    shopify.idToken().then((value) => {
      _this.pushEvent("ShopifyUserToken:mounted", { session_token: value });
    });
  },
};

export const ShopifyModal = {
  mounted() {
    id = this.el.id;
    this.handleEvent(`polaris:modal_show_${id}`, (event) =>
      this.liveSocket.execJS(this.el, this.el.getAttribute("data-show")),
    );
    this.handleEvent(`polaris:modal_hide_${id}`, (event) =>
      this.liveSocket.execJS(this.el, this.el.getAttribute("data-hide")),
    );
  },
};

export const UnauthenticatedRedirect = {
  mounted() {
    el = this.el;
    this.handleEvent("UnauthenticatedRedirect", (data) => el.click());
  },
};
