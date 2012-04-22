
/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * UUID.java                                              *
 *                                                        *
 * UUID for Java.                                         *
 *                                                        *
 * LastModified: Jul 19, 2010                             *
 * Author: Ma Bingyao <andot@hprfc.com>                   *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

public final class UUID
implements java.io.Serializable, Comparable {

     private static final long serialVersionUID = -4856846361193249489L;

    private final long mostSigBits;
    private final long leastSigBits;
    private transient int version = -1;
    private transient int variant = -1;
    private transient volatile long timestamp = -1;
    private transient int sequence = -1;
    private transient long node = -1;
    private transient int hashCode = -1;
    private static volatile SecureRandom numberGenerator = null;

    private UUID(byte[] data) {
        long msb = 0;
        long lsb = 0;
        for (int i=0; i<8; i++)
            msb = (msb << 8) | (data[i] & 0xff);
        for (int i=8; i<16; i++)
            lsb = (lsb << 8) | (data[i] & 0xff);
        this.mostSigBits = msb;
        this.leastSigBits = lsb;
    }

    public UUID(long mostSigBits, long leastSigBits) {
        this.mostSigBits = mostSigBits;
        this.leastSigBits = leastSigBits;
    }

    public static UUID randomUUID() {
        SecureRandom ng = numberGenerator;
        if (ng == null) {
            numberGenerator = ng = new SecureRandom();
        }

        byte[] randomBytes = new byte[16];
        ng.nextBytes(randomBytes);
        randomBytes[6]  &= 0x0f;  /* clear version        */
        randomBytes[6]  |= 0x40;  /* set to version 4     */
        randomBytes[8]  &= 0x3f;  /* clear variant        */
        randomBytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(randomBytes);
    }

    public static UUID nameUUIDFromBytes(byte[] name) {
        MessageDigest md;
        try {
            md = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException nsae) {
            throw new InternalError("MD5 not supported");
        }
        byte[] md5Bytes = md.digest(name);
        md5Bytes[6]  &= 0x0f;  /* clear version        */
        md5Bytes[6]  |= 0x30;  /* set to version 3     */
        md5Bytes[8]  &= 0x3f;  /* clear variant        */
        md5Bytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(md5Bytes);
    }

    public static UUID fromString(String name) {
        String[] components = name.split("-");
        if (components.length != 5)
            throw new IllegalArgumentException("Invalid UUID string: "+name);
        for (int i=0; i<5; i++)
            components[i] = "0x"+components[i];

        long mostSigBits = Long.decode(components[0]).longValue();
        mostSigBits <<= 16;
        mostSigBits |= Long.decode(components[1]).longValue();
        mostSigBits <<= 16;
        mostSigBits |= Long.decode(components[2]).longValue();

        long leastSigBits = Long.decode(components[3]).longValue();
        leastSigBits <<= 48;
        leastSigBits |= Long.decode(components[4]).longValue();

        return new UUID(mostSigBits, leastSigBits);
    }

    public long getLeastSignificantBits() {
        return leastSigBits;
    }

    public long getMostSignificantBits() {
        return mostSigBits;
    }

    public int version() {
        if (version < 0) {
            // Version is bits masked by 0x000000000000F000 in MS long
            version = (int)((mostSigBits >> 12) & 0x0f);
        }
        return version;
    }

    public int variant() {
        if (variant < 0) {
            // This field is composed of a varying number of bits
            if ((leastSigBits >>> 63) == 0) {
                variant = 0;
            } else if ((leastSigBits >>> 62) == 2) {
                variant = 2;
            } else {
                variant = (int)(leastSigBits >>> 61);
            }
        }
        return variant;
    }

    public long timestamp() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }
        long result = timestamp;
        if (result < 0) {
            result = (mostSigBits & 0x0000000000000FFFL) << 48;
            result |= ((mostSigBits >> 16) & 0xFFFFL) << 32;
            result |= mostSigBits >>> 32;
            timestamp = result;
        }
        return result;
    }

    public int clockSequence() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }
        if (sequence < 0) {
            sequence = (int)((leastSigBits & 0x3FFF000000000000L) >>> 48);
        }
        return sequence;
    }

    public long node() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }
        if (node < 0) {
            node = leastSigBits & 0x0000FFFFFFFFFFFFL;
        }
        return node;
    }

    public String toString() {
	return (digits(mostSigBits >> 32, 8) + "-" +
		digits(mostSigBits >> 16, 4) + "-" +
		digits(mostSigBits, 4) + "-" +
		digits(leastSigBits >> 48, 4) + "-" +
		digits(leastSigBits, 12));
    }

    private static String digits(long val, int digits) {
	long hi = 1L << (digits * 4);
	return Long.toHexString(hi | (val & (hi - 1))).substring(1);
    }

    public int hashCode() {
        if (hashCode == -1) {
            hashCode = (int)((mostSigBits >> 32) ^
                             mostSigBits ^
                             (leastSigBits >> 32) ^
                             leastSigBits);
        }
        return hashCode;
    }

    public boolean equals(Object obj) {
	if (!(obj instanceof UUID))
	    return false;
        if (((UUID)obj).variant() != this.variant())
            return false;
        UUID id = (UUID)obj;
	return (mostSigBits == id.mostSigBits &&
                leastSigBits == id.leastSigBits);
    }

    public int compareTo(UUID val) {
        // The ordering is intentionally set up so that the UUIDs
        // can simply be numerically compared as two numbers
        return (this.mostSigBits < val.mostSigBits ? -1 :
                (this.mostSigBits > val.mostSigBits ? 1 :
                 (this.leastSigBits < val.leastSigBits ? -1 :
                  (this.leastSigBits > val.leastSigBits ? 1 :
                   0))));
    }

    private void readObject(java.io.ObjectInputStream in)
        throws java.io.IOException, ClassNotFoundException {

        in.defaultReadObject();

        // Set "cached computation" fields to their initial values
        version = -1;
        variant = -1;
        timestamp = -1;
        sequence = -1;
        node = -1;
        hashCode = -1;
    }

    public int compareTo(Object o) {
        return compareTo((UUID) o);
    }
}