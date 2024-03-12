package zimo;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
//字模转化代码
public class trans {
    public static void main(String[] args) throws IOException {
        BufferedReader bufferedReader = new BufferedReader(new FileReader("C:\\Users\\86178\\Desktop\\vivodo\\proje\\pepsi.TXT"));
        int i = 0;
        String s;
        while ((s=bufferedReader.readLine())!=null){
            if (s.contains("zy")) {
                System.out.println(s.replaceAll("char","      char").replaceAll("zy", String.valueOf(i)));
                i++;
            }
        }
    }
}
