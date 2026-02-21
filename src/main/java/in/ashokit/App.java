package in.ashokit;

import java.util.logging.Logger;

/**
 * Hello world!
 *
 */
public class App {

    private static final Logger logger = Logger.getLogger(App.class.getName());
    private static final String MESSAGE = "Hello World!";

    public static void main(String[] args) {
        logger.info(MESSAGE);
    }

    public String getMessage() {
        return MESSAGE;
    }
}
