import org.jpos.iso.*;
import org.jpos.util.*;
import org.jpos.iso.channel.ASCIIChannel;
import org.jpos.iso.packager.GenericPackager;
import org.jpos.util.LogListener;
import org.jpos.util.SimpleLogListener;


public class Test_java_client {
	public static void main (String[] args) throws Exception {
		Logger logger = new Logger();
		logger.addListener (new SimpleLogListener (System.out));
		ISOChannel channel = new ASCIIChannel ("localhost", 8005, new GenericPackager("iso93ascii.xml"));
		((LogSource)channel).setLogger (logger, "test-channel");
		channel.connect ();
		//GenericPackager packager = new GenericPackager("iso93ascii.xml");
		ISOMsg m = new ISOMsg ();
		m.setMTI("0200");
		m.set(2, "1231231312");		
		m.set(3, "201234");
		m.set(4, "000010000000");
		m.set(7, "1107221800");
		m.set(11, "123456");
		m.set(12,"161009132458");
		m.set(32,"414243");
		m.set(41, "termid12");
		m.set(43,"Community1");
		m.set(44, "A5DFGR");
		m.set(39,"000");
		m.set(102,"12341234234");
		m.set(22,"FABCDE123ABD");
		GenericPackager packager = new GenericPackager("iso93ascii.xml");
		m.setPackager (packager);
		byte[] data = m.pack();
		// print the DE list
		System.out.println("RESULT : " + new String(data));
/**
7220000100B00000
0111001000100000000000000000000100000000101100000000000000000000
**/

		for (int i=1;i<=5000;i++)
		{
		channel.send (m);
		ISOMsg r = channel.receive ();
		}
		
		channel.disconnect ();
	}
}




/**
 * 
 * 
 * /**m.setMTI ("2210");
		m.set(2,"4889889898778");
		m.set (3, "000000");
		m.set (4, "000000002059");
		m.set (11, "012883");
		m.set (11, "000000012883");
		m.set (12, "161001075456");
		m.set (32, "414243");
		m.set (39, "0000");
		m.set (41, "0000000080000001");
		m.set (42, "811234567890101");
		m.set (49, "826");
		m.set (53, "FEDCBA9876543210");
		//m.set (64, "0011223344556677");
		* 
		* 
 * [Fixed    n               6 006] 003       [000000]
[Fixed    n              12 012] 004       [000000002059]
[Fixed    n               6 006] 011       [012883]
[Fixed    YYMMDDhhmmss   12 012] 012       [161001075456]
[LLVAR    n            ..11 006] 032       [414243]
[Fixed    n               3 003] 039       [000]
[Fixed    ans             8 008] 041       [80000001]
[Fixed    ans            15 015] 042       [811234567890101]
[Fixed    an              3 003] 049       [826]
[LLVAR    b            ..48 016] 053      *[FEDCBA9876543210]
[Fixed    b               8 016] 064      *[0011223344556677]
* 
* javac -cp .:/home/nuku/Documents/PROJECTS/java/jPOS/jpos/build/libs/jpos-2.0.7-SNAPSHOT.jar Test_java_client.java
* 
*javac -cp ".;/home/path/mail.jar;/home/path/servlet.jar;" MyJavaFile.java
javac -classpath ".;/home/path/mail.jar;/home/path/servlet.jar;" MyJavaFile.java 
* 
*java -Xbootclasspath/p:/home/nuku/Documents/PROJECTS/java/jPOS/jpos/build/libs/jpos-2.0.7-SNAPSHOT.jar Test_java_client
**/
