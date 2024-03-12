package zimo;
//Vga快速撰写代码
public class give {
    public static void main(String[] args) {
        int a = 0;
        for (int i = 128; i < 192; i++) {
            String ci = String.valueOf(i/64);
            String ge ;
            if (i<10) ge = "  ";
            else ge ="";
            if (a==64) a=0;
            System.out.println("    char["+ge+String.valueOf(i)+"] <= {char"+ci+ci+"_0["+a+"],char"+ci+ci+"_1["+a+"],char"+ci+ci+"_2["+a+"],char"+ci+ci+"_3["+a+"],char"+ci+ci+"_4["+a+"],char"+ci+"["+a+"]};");
            //System.out.println("    char["+ge+String.valueOf(i)+"] <= 512'h0;");
            //System.out.println("    char22_0["+i+"] <= char22_0["+i+"];");
            //System.out.println("    char22["+i+"] <= {char22_4["+i+"],char22_3["+i+"],char22_2["+i+"],char22_1["+i+"],char22_0["+i+"]};");
            a++;

        }
    }
}
