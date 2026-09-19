import gi
import os
import sys

gi.require_version('Gtk', '4.0')
gi.require_version('WebKit', '6.0')
from gi.repository import Gtk, WebKit, Gio, GLib

class TorBrowserWindow(Gtk.ApplicationWindow):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_title("Tor Browser (Termux Pro)")
        self.set_default_size(1024, 768)

        # Main Layout
        self.vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.set_child(self.vbox)

        # Toolbar
        self.toolbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.toolbar.set_margin_top(6)
        self.toolbar.set_margin_bottom(6)
        self.toolbar.set_margin_start(6)
        self.toolbar.set_margin_end(6)
        self.vbox.append(self.toolbar)

        # Navigation Buttons
        self.btn_back = Gtk.Button.new_from_icon_name("go-previous-symbolic")
        self.btn_back.connect("clicked", self.on_back_clicked)
        self.toolbar.append(self.btn_back)

        self.btn_forward = Gtk.Button.new_from_icon_name("go-next-symbolic")
        self.btn_forward.connect("clicked", self.on_forward_clicked)
        self.toolbar.append(self.btn_forward)

        self.btn_reload = Gtk.Button.new_from_icon_name("view-refresh-symbolic")
        self.btn_reload.connect("clicked", self.on_reload_clicked)
        self.toolbar.append(self.btn_reload)

        # Address Bar
        self.url_entry = Gtk.Entry()
        self.url_entry.set_hexpand(True)
        self.url_entry.connect("activate", self.on_url_activate)
        self.toolbar.append(self.url_entry)

        # Tor Status
        self.status_label = Gtk.Label(label="🟢 Tor Connected")
        self.status_label.set_css_classes(["success-label"])
        self.toolbar.append(self.status_label)

        # Web View
        self.web_view = WebKit.WebView()
        self.web_view.set_vexpand(True)
        self.vbox.append(self.web_view)

        # Initial Load
        self.url_entry.set_text("https://check.torproject.org")
        self.web_view.load_uri("https://check.torproject.org")

    def on_url_activate(self, entry):
        url = entry.get_text()
        if not url.startswith("http"):
            url = "https://" + url
        self.web_view.load_uri(url)

    def on_back_clicked(self, btn):
        self.web_view.go_back()

    def on_forward_clicked(self, btn):
        self.web_view.go_forward()

    def on_reload_clicked(self, btn):
        self.web_view.reload()

class TorBrowserApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="org.torproject.torbrowser",
                         flags=Gio.ApplicationFlags.FLAGS_NONE)

    def do_activate(self):
        win = TorBrowserWindow(application=self)
        win.present()

if __name__ == "__main__":
    app = TorBrowserApp()
    app.run(sys.argv)
