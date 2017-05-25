import org.jpos.iso.*;
import org.jpos.util.*;
import org.jpos.iso.channel.PostChannel;
import org.jpos.iso.packager.GenericPackager;
import org.jpos.util.LogListener;
import org.jpos.util.SimpleLogListener;
import java.text.SimpleDateFormat;
import java.util.Date;

//this is for sending transactions to the transaction socket server for testing purposes 
public class Test_java_client_post {
	public static void main (String[] args) throws Exception {
		Logger logger = new Logger();
		logger.addListener (new SimpleLogListener (System.out));
		PostChannel channel = new PostChannel ("localhost", 8005, new GenericPackager("ecopostpack.xml"));
		((LogSource)channel).setLogger (logger, "test-channel");
		
		//GenericPackager packager = new GenericPackager("iso93ascii.xml");
		ISOMsg m = new ISOMsg ();
		m.setMTI("0200");
		m.set(2, "1231231312");		
		m.set(3, "201234");
		m.set(4, "000010000000");
		m.set(7, "1107221800");
		Date today = new Date();
		SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyMMdd");
		m.set(12,DATE_FORMAT.format(today));
		m.set(14,"0205");
	    m.set(18,"5399");
		m.set(22,"123");
		m.set(25,"00");
		m.set(32,"414243");
		m.set(37,"206305000014");
		m.set(39,"00");
		m.set(41, "termid");
		m.set(42, "termid12");
		m.set(43,"Community1Community1Community1Community1");
		m.set(44, "A5DFGR");
		m.set(49, "840");
		m.set(102,"12341234234");
//01110010001101000100010010000001000010101111000010000000000000000011000100110000001100010011001000110011001100010011001000110011	
		channel.connect ();
		for (int i=1;i<=10000;i++)
		{
		
		m.set(11,String.valueOf(i));
		
		//m.dump(System.out,"\t");
		channel.send (m);
		ISOMsg r = channel.receive ();
		}
		
		channel.disconnect ();
		
		
	}
}

/**
 * 
 * 
* to compile in new changes
*javac -cp .:jpos-2.0.7-SNAPSHOT.jar Test_java_client_post.java 
*to run new changes 
* java -Xbootclasspath/p:jpos-2.0.7-SNAPSHOT.jar Test_java_client_post -- to start one instance of sending data
*  ./test_trans.sh 10 --to run as many instances as you want using shell scripts 
do
   java -Xbootclasspath/p:jpos-2.0.7-SNAPSHOT.jar Test_java_client_post &
done 
**/
