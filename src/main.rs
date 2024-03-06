use gtk::prelude::*;
use gtk::{glib, Application, ApplicationWindow};
use gtk4_layer_shell::{Edge, Layer, LayerShell};
use webkit6::prelude::*;
use webkit6::WebView;
use clap::Parser;

const APP_ID: &str = "at.lolc.WebKitBg";

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// The URI to load as the background
    uri: String
}

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();
    
    app.connect_activate(build_ui);
    app.run_with_args::<glib::GString>(&[])
}

fn build_ui(app: &Application) {
    let args = Args::parse();

    // Set up WebView
    let web_view = WebView::new();
    web_view.load_uri(&args.uri);

    // Set up window
    let window = ApplicationWindow::builder()
        .application(app)
        .child(&web_view)
        .build();

    window.init_layer_shell();
    window.set_layer(Layer::Background);

    let anchors = [
        (Edge::Left, true),
        (Edge::Right, true),
        (Edge::Top, true),
        (Edge::Bottom, true),
    ];

    for (anchor, state) in anchors {
        window.set_anchor(anchor, state);
    }

    // ready
    window.present();
}
