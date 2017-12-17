import java.io.File;
import java.io.FileNotFoundException;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.util.List;
import java.util.ArrayList;;

public class Assembler {

    private static final String  FORMAT                 = "mti";
    private static final char    ADDR_RADIX             = 'd';
    private static final char    DATA_RADIX             = 'b';
    private static final double  VERSION                = 1.0;
    private static final Integer WORDS_PER_LINE         = 10;
    private static final String  MEMRORY_FILE_EXTENSION = ".mem";

    private static final String MEMORY_FILE_HEADER = 
    "// memory data file (do not edit the following line - required for mem load use)\n"
    + "// format=" + FORMAT + ' '
    + "addressradix=" + ADDR_RADIX + ' '
    + "dataradix=" + DATA_RADIX + ' '
    + "version=" + String.valueOf(VERSION) + ' '
    + "wordsperline=" + String.valueOf(WORDS_PER_LINE)
    + "\n";

    public static void main(String[] args) {

        if(args.length < 2){
            System.out.println("Usage "+Assembler.class.getName()+": filename memory-folder");
            System.exit(1);
        }

        compileFile(args[0], args[1]);
    }
        
    public static void compileFile(String inpFilename, String memoryFolder){
        BufferedReader reader = null;
        BufferedWriter writer = null;

        if(memoryFolder.charAt(memoryFolder.length()-1) != '/') 
            memoryFolder += '/';
        String outpFilename = memoryFolder
                            + inpFilename.substring(inpFilename.lastIndexOf('/'), inpFilename.lastIndexOf('.'))
                            + MEMRORY_FILE_EXTENSION;

        try{
            File inpFile  = new File(inpFilename);
            File outpFile = new File(outpFilename);

            reader = new BufferedReader(new FileReader(inpFile));
            writer = new BufferedWriter(new FileWriter(outpFile));

            writer.write(MEMORY_FILE_HEADER);

            String line;
            while ((line = reader.readLine()) != null)
                writer.write(parseLine(line)+'\n');
        }
        catch (FileNotFoundException e){
            e.printStackTrace();
        }
        catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
                if (writer != null){
                    writer.close();
                }
            }catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private static String parseLine(String line){
        return line;
    }
}
