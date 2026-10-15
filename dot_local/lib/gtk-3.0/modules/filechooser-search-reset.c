#include <gtk/gtk.h>
#include <gmodule.h>

/* Loaded only in xdg-desktop-portal-gtk. Empty search restores folder browsing. */
typedef struct { GtkWidget *entry; GtkWidget *chooser; } Pending;

static gboolean reset_search(gpointer data) {
    Pending *p = data;
    gboolean searching = FALSE;
    g_object_get(p->chooser, "search-mode", &searching, NULL);
    if (searching && gtk_widget_get_realized(p->chooser) &&
        gtk_entry_get_text(GTK_ENTRY(p->entry))[0] == '\0')
        g_object_set(p->chooser, "search-mode", FALSE, NULL);
    return G_SOURCE_REMOVE;
}

static void free_pending(gpointer data) {
    Pending *p = data;
    g_object_unref(p->entry);
    g_object_unref(p->chooser);
    g_free(p);
}

static void search_changed(GtkSearchEntry *entry, GtkWidget *chooser) {
    if (gtk_entry_get_text(GTK_ENTRY(entry))[0] != '\0') return;
    Pending *p = g_new(Pending, 1);
    p->entry = GTK_WIDGET(g_object_ref(entry));
    p->chooser = g_object_ref(chooser);
    g_idle_add_full(G_PRIORITY_DEFAULT_IDLE, reset_search, p, free_pending);
}

static void attach_search(GtkWidget *widget, gpointer chooser) {
    if (GTK_IS_SEARCH_ENTRY(widget) &&
        !g_object_get_data(G_OBJECT(widget), "filechooser-search-reset")) {
        g_object_set_data(G_OBJECT(widget), "filechooser-search-reset", GINT_TO_POINTER(1));
        g_signal_connect_object(widget, "search-changed", G_CALLBACK(search_changed),
                                G_OBJECT(chooser), 0);
    }
    if (GTK_IS_CONTAINER(widget))
        gtk_container_forall(GTK_CONTAINER(widget), attach_search, chooser);
}

static gboolean widget_mapped(GSignalInvocationHint *hint, guint n,
                              const GValue *values, gpointer unused) {
    (void)hint; (void)n; (void)unused;
    GtkWidget *widget = g_value_get_object(&values[0]);
    if (GTK_IS_FILE_CHOOSER_WIDGET(widget))
        attach_search(widget, widget);
    return TRUE;
}

G_MODULE_EXPORT void gtk_module_init(gint *argc, gchar ***argv) {
    (void)argc; (void)argv;
    gpointer widget_class = g_type_class_ref(GTK_TYPE_WIDGET);
    g_signal_add_emission_hook(g_signal_lookup("map", GTK_TYPE_WIDGET), 0,
                              widget_mapped, NULL, NULL);
    g_type_class_unref(widget_class);
}
