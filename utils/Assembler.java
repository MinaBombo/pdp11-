import java.io.File;
import java.io.FileNotFoundException;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Scanner;

public class Assembler {

    private static final String  FORMAT                = "mti";
    private static final char    ADDR_RADIX            = 'd';
    private static final char    DATA_RADIX            = 'b';
    private static final double  VERSION               = 1.0;
    private static final Integer WORDS_PER_LINE        = 1;
    private static final String  MEMORY_FILE_EXTENSION = ".mem";

    private static final String ADDR_MODE_DIR_REG  = "00";
    private static final String ADDR_MODE_AUTO_INC = "01";
    private static final String ADDR_MODE_AUTO_DEC = "10";
    private static final String ADDR_MODE_INDEXED  = "11";

    private static final List<String> Operations = Arrays.asList(
            "MOV", "ADD", "ADC", "SUB", "SBC", "AND", "OR", "XOR", "BIC", "CMP",
            "INC", "DEC", "INV", "LSR", "ROR", "RRC", "ASR", "LSL", "ROL", "RLC",
            "BR", "BEQ", "BNE", "BLO", "BLS", "BHI", "BHS",
            "HLT", "NOP", "RESET",
            "JSR", "RTS"
    );

    private static final String MEMORY_FILE_HEADER =
            "// memory data file (do not edit the following line - required for mem load use)\n"
                    + "// format=" + FORMAT + ' '
                    + "addressradix=" + ADDR_RADIX + ' '
                    + "dataradix=" + DATA_RADIX + ' '
                    + "version=" + String.valueOf(VERSION) + ' '
                    + "wordsperline=" + String.valueOf(WORDS_PER_LINE)
                    + "\n";

    private static final Integer RAM_H = 2048;
    private static final Integer RAM_W = 16;
    private static String[] mRam = new String[RAM_H];
    private static Integer[] mX = { -1, -1};
    private static Integer mCurrAddress = 0;
    private static boolean mIsDataNext = false;
    private static HashMap<String, Integer> mLabelsToAddr = new HashMap<String, Integer>();

    private class CompilationErrorException extends RuntimeException{
        public CompilationErrorException(String message) {
            super(message);
        }
    }

    public void CompileFile(String inpFilename, String memoryFolder){
        BufferedReader reader = null;
        BufferedWriter writer = null;

        if(memoryFolder.charAt(memoryFolder.length()-1) != '/')
            memoryFolder += '/';
        String outpFilename = memoryFolder
                + inpFilename.substring(inpFilename.lastIndexOf('/'), inpFilename.lastIndexOf('.'))
                + MEMORY_FILE_EXTENSION;

        try{
            File inpFile  = new File(inpFilename);
            File outpFile = new File(outpFilename);

            reader = new BufferedReader(new FileReader(inpFile));
            writer = new BufferedWriter(new FileWriter(outpFile));

            writer.write(MEMORY_FILE_HEADER);

            String line;
            for(int i=0; i<RAM_H; ++i)
                mRam[i] = String.format("%0" + RAM_W + "d", 0);
            while ((line = reader.readLine()) != null) {
                String parsedLine = parseLine(line);
                if(parsedLine != null) {
                    System.out.println(line + " : " + parsedLine);
                    mRam[mCurrAddress++] = parsedLine;
                    for(int i=0; i<2; ++i){
                        if(mX[i] != -1){
                            mRam[mCurrAddress++] = Integer.
                                    toBinaryString(((int) Math.pow(2, 16)) | mX[i])
                                    .substring(1);
                            System.out.println("X" + String.valueOf(i) + " : " + mRam[mCurrAddress-1]);
                            mX[i] = -1;
                        }
                    }
                }else{
                    if(mIsDataNext && line.length() > 0 && line.charAt(0) == '/'){
                        while ((line = reader.readLine()) != null){
                            String[] parts = line.split(" ");
                            String data1 = Integer.
                            toBinaryString(((int) Math.pow(2, 16)) | Integer.parseUnsignedInt(parts[1]) /(int)Math.pow(2, 16))
                            .substring(1);
                            String data2 = Integer.
                            toBinaryString(((int) Math.pow(2, 16)) | Integer.parseUnsignedInt(parts[1]) %(int)Math.pow(2, 16))
                            .substring(1);
                            mRam[Integer.parseInt(parts[0])]    = data2;
                            mRam[Integer.parseInt(parts[0]) +1] = data1; 
                            System.out.println(parts[1]
                            +  " : " + data1 + "," + data2 );
                        }
                    }
                }
            }

            for (int i = RAM_H-1; i>=0; --i){
                if(mRam[i].contains(".")){
                    int size = ((int) Math.pow(2, 11));
                    int addr = mLabelsToAddr.get(mRam[i].substring(7));
                    if(mRam[i].charAt(mRam[i].indexOf('.') +1 ) == 'J')
                        writer.write(String.format("%4d", i)
                                + ": " + mRam[i].substring(0, 5)
                                + Integer.toBinaryString(size | addr).substring(1)
                                +"\n");
                    else{ 
                        String offset = Integer.toBinaryString(size | (addr -(i + 1)));
                        if(offset.length() == 32) 
                            offset = offset.substring(21);
                        else
                            offset = offset.substring(1);

                        String toWrite = String.format("%4d", i)
                        + ": " + mRam[i].substring(0, 5)
                        + offset
                        + "\n";
                        writer.write(toWrite);
                    }
                } else{
                    writer.write(String.format("%4d", i)
                                + ": " + mRam[i]+"\n");
                }
            }
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

    private String parseOperand(String operand, int index) throws CompilationErrorException{
        String parsedOp = "";
        String xRange = "([0-9]" +
                        "|[1-9][0-9]" +
                        "|[1-9][0-9][0-9]" +
                        "|[1-9][0-9][0-9][0-9]" +
                        "|[1-5][0-9][0-9][0-9][0-9]" +
                        "|6([0-4][0-9][0-9][0-9]" +
                            "|5([0-4][0-9][0-9]" +
                                "|5([0-2][0-9]" +
                                    "|3[0-5]))))";
        if(operand.matches("(?i)(r[0-3])"))
            parsedOp +=  ADDR_MODE_DIR_REG;
        else if(operand.matches("\\((?i)(r[0-3])\\)\\+"))
            parsedOp += ADDR_MODE_AUTO_INC;
        else if(operand.matches("-\\((?i)(r[0-3])\\)"))
            parsedOp += ADDR_MODE_AUTO_DEC;
        else if(operand.matches(xRange + "\\((?i)(r[0-3])\\)")) {
            parsedOp += ADDR_MODE_INDEXED;
            int x = new Scanner(operand).useDelimiter("\\D+").nextInt();
            mX[index] = x;
            operand = operand.substring(String.valueOf(x).length());
        }
        else
            throw new CompilationErrorException("Illegal Operand: " + operand);

        int regNum = Integer.parseInt(operand.replaceAll("[\\D]", ""));
        parsedOp += Integer.toBinaryString(((int) Math.pow(2, 3)) | regNum).substring(1);

        if(regNum > 3)
            throw new CompilationErrorException("Illegal Operand: " + operand);

        return  parsedOp;
    }

    private String parseInstruction(String instr, String[] operands){
        int size5  = ((int) Math.pow(2, 5));

        // No operands
        if(instr.matches("\\b(?i)(hlt|nop|reset|rts)\\b"))
            return Integer.toBinaryString(size5 | Operations.indexOf(instr.toUpperCase())).substring(1)
                    + String.format("%0" + 11 + "d", 0);

        // Branches and JSR
        else if(instr.matches("\\b(?i)(b((l[o|s])|(h[i|s])|eq|nq|r)|jsr)\\b"))
            return Integer.toBinaryString(size5 | Operations.indexOf(instr.toUpperCase())).substring(1)
                    + '.' + instr.charAt(0) + operands[0];

        // Single operands
        else if(instr.matches("\\b(?i)(bic|in[c|v]|ro[r|l]|ls[r|l]|dec|r[r|l]c|asr)\\b"))
            return Integer.toBinaryString(size5 | Operations.indexOf(instr.toUpperCase())).substring(1)
                    + parseOperand(operands[0], 0)
                    + parseOperand(operands[0], 0)
                    + '0';

        // Double operands
        else if(instr.matches("\\b(?i)(mov|ad[d|c]|sub|sbc|and|x?or|cmp)\\b"))
            return Integer.toBinaryString(size5 | Operations.indexOf(instr.toUpperCase())).substring(1)
                    + parseOperand(operands[0], 0)
                    + parseOperand(operands[1], 1)
                    + '0';

        // BIS = OR
        else if(instr.matches("\\b(?i)bis\\b"))
            return Integer.toBinaryString(size5 | Operations.indexOf("OR")).substring(1)
                    + parseOperand(operands[0], 0)
                    + parseOperand(operands[1], 1)
                    + '0';

        // CLR = DST XOR DST
        else if(instr.matches("\\b(?i)clr\\b"))
            return Integer.toBinaryString(size5 | Operations.indexOf("XOR")).substring(1)
                    + parseOperand(operands[0], 0)
                    + parseOperand(operands[0], 0)
                    + '0';

        else
            throw new CompilationErrorException("Illegal Instruction: " + instr);
    }

    private String parseLine(String line){
        if(line.length() == 0)
            return null;

        if(line.charAt(0) == '/' ){
            mIsDataNext = true;
            return null;
        }

        String parts[] = line.split(":");
        if(parts.length > 1) {
            mLabelsToAddr.put(parts[0], mCurrAddress);
            line = line.substring(parts[0].length() +2);
        }

        parts = line.split(" ");
        String instr = parts[0];
        line = line.substring(instr.length());
        if(line.length() > 0)
            line = line.substring(1);
        String operands[] = line.split(",");

        return parseInstruction(parts[0], operands);
    }
}

class main {
    public static void main(String[] args) {

        if (args.length < 2) {
            System.out.println("Usage Assembler: filename memory-folder");
            System.exit(1);
        }

        new Assembler().CompileFile(args[0], args[1]);
    }
}

