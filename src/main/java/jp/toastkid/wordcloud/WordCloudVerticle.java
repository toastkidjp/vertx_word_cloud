package jp.toastkid.wordcloud;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.handler.StaticHandler;
import io.vertx.ext.web.handler.TemplateHandler;
import io.vertx.ext.web.templ.FreeMarkerTemplateEngine;

/**
 * Word cloud powered by Vert.x ver 3.
 *
 * @author Toast kid
 */
public class WordCloudVerticle extends AbstractVerticle {

    /** width of word-cloud. */
    private static final int WIDTH  = 900;

    /** height of word-cloud. */
    private static final int HEIGHT = 600;

    /** Title. */
    private static final String TITLE = "Word Cloud";

    @Override
    public void start(final Future<Void> future) {
        vertx
            .createHttpServer()
            .requestHandler(route()::accept)
            .listen(8940, result -> {
                if (result.succeeded()) {
                    future.complete();
                } else {
                    future.fail(result.cause());
                }
            });
    }

    /**
     * routing.
     */
    private Router route() {

        // single page entry points.
        final Router sub = Router.router(vertx);
        sub.get("/").handler(handler -> handler.response().end("Hello Vert.x app."));

        final Router main = Router.router(vertx).mountSubRouter("/", sub);

        // static resources.
        main.route("/assets/*").handler(StaticHandler.create("assets"));

        final TemplateHandler handler = TemplateHandler.create(
                FreeMarkerTemplateEngine.create(), "/templates/", "text/html");

        // word cloud app route.
        main.get("/wc").handler(context -> {
            context.put("title",  TITLE);

            final String sentence = context.request().getParam("sentence");

            if (sentence == null || sentence.trim().length() == 0) {
                handler.handle(context);
                return;
            }
            context.put("wcData",        new WordCloud().count(sentence));
            context.put("paramSentence", sentence);
            context.put("width",         WIDTH);
            context.put("height",        HEIGHT);
            handler.handle(context);
        });
        return main;
    }
}
