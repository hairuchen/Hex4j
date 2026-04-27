package me.chr.hex4j;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.PrintStream;

@SpringBootApplication
@Slf4j
public class Hex4jApplication {

    public static void main(String[] args) {
        // 将 System.out 和 System.err 重定向到 logger
        System.setOut(createLoggingPrintStream(System.out));
        System.setErr(createLoggingPrintStream(System.err));

        SpringApplication.run(Hex4jApplication.class, args);

        log.info("========================================");
        log.info("  Hex4j Application Started Successfully!");
        log.info("========================================");
    }

    /**
     * 把 System.out 和 System.err 替换为新的 PrintStream，用 logger.info 代替所有输出
     * @param originalStream 原始 PrintStream
     * @return 包装后的 PrintStream
     */
    private static PrintStream createLoggingPrintStream(final PrintStream originalStream) {
        return new PrintStream(originalStream) {
            public void print(final String string) {
                log.info(string);
            }
            public void println(final String string) {
                log.info(string);
            }
        };
    }

}
