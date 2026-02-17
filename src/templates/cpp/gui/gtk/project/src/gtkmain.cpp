#include <gtk/gtk.h>

static void on_activate(GtkApplication* app, gpointer)
{
    GtkWidget* window = gtk_application_window_new(app);

    gtk_window_set_default_size(GTK_WINDOW(window), 640, 480);
    gtk_window_present(GTK_WINDOW(window));
}

int main(int argc, char** argv)
{
    GtkApplication* app;
    int status;

    app = gtk_application_new("com.croicu.gtkmin", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), nullptr);

    status = g_application_run(G_APPLICATION(app), argc, argv);

    g_object_unref(app);
    return status;
}