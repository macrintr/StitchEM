package foo.bar;

import net.imagej.updater.DefaultUpdateService;
import net.imagej.updater.UpdateService;

import org.scijava.Priority;
import org.scijava.plugin.Plugin;
import org.scijava.service.Service;
import org.scijava.ui.event.UIShownEvent;

// From https://github.com/imagej/imagej-updater/issues/7

/** {@link UpdateService} which disables update checking at startup. */
@Plugin(type = Service.class, priority = Priority.HIGH_PRIORITY)
public class NoUpdaterUpdateService extends DefaultUpdateService {

    // -- Event handlers --

    /** Override the initial update check, to never do anything. */
    @Override
    protected void onEvent(final UIShownEvent evt) {
        // NB: Do nothing.
    }

}