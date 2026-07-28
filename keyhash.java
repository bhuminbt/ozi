import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.cert.Certificate;
import java.util.Base64;

public class KeyHash {
    public static void main(String[] args) throws Exception {

        String keystore = System.getProperty("user.home") + "\\.android\\debug.keystore";

        KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());

        ks.load(new FileInputStream(keystore), "android".toCharArray());

        Certificate cert = ks.getCertificate("androiddebugkey");

        MessageDigest md = MessageDigest.getInstance("SHA");

        md.update(cert.getEncoded());

        System.out.println(Base64.getEncoder().encodeToString(md.digest()));
    }
}