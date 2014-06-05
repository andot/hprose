/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
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
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
package hprose.common;

import java.util.Random;

public final class UUID {
    private final long mostSigBits;
    private final long leastSigBits;
    private static volatile Random numberGenerator = null;

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
        Random ng = numberGenerator;
        if (ng == null) {
            numberGenerator = ng = new Random();
        }

        byte[] randomBytes = new byte[16];
        for (int i = 0; i < 16; i++) {
            randomBytes[i] = (byte)(ng.nextInt() & 0xff);
        }
        randomBytes[6]  &= 0x0f;  /* clear version        */
        randomBytes[6]  |= 0x40;  /* set to version 4     */
        randomBytes[8]  &= 0x3f;  /* clear variant        */
        randomBytes[8]  |= 0x80;  /* set to IETF variant  */
        return new UUID(randomBytes);
    }

    public static UUID fromString(String name) {
        String[] components = new String[5];
        components[0] = name.substring(0, 8);
        components[1] = name.substring(9, 13);
        components[2] = name.substring(14, 18);
        components[3] = name.substring(19, 23);
        components[4] = name.substring(24, 26);
        long mostSigBits = Long.parseLong(components[0], 16);
        mostSigBits <<= 16;
        mostSigBits |= Long.parseLong(components[1], 16);
        mostSigBits <<= 16;
        mostSigBits |= Long.parseLong(components[2], 16);

        long leastSigBits = Long.parseLong(components[3], 16);
        leastSigBits <<= 48;
        leastSigBits |= Long.parseLong(components[4], 16);

        return new UUID(mostSigBits, leastSigBits);
    }

    public long getLeastSignificantBits() {
        return leastSigBits;
    }

    public long getMostSignificantBits() {
        return mostSigBits;
    }

    public int version() {
        return (int)((mostSigBits >> 12) & 0x0f);
    }

    public int variant() {
        int variant;
        if ((leastSigBits >>> 63) == 0) {
            variant = 0;
        } else if ((leastSigBits >>> 62) == 2) {
            variant = 2;
        } else {
            variant = (int)(leastSigBits >>> 61);
        }
        return variant;
    }

    public long timestamp() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }
        long result;
        result = (mostSigBits & 0x0000000000000FFFL) << 48;
        result |= ((mostSigBits >> 16) & 0xFFFFL) << 32;
        result |= mostSigBits >>> 32;
        return result;
    }

    public int clockSequence() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }
        return (int)((leastSigBits & 0x3FFF000000000000L) >>> 48);
    }

    public long node() {
        if (version() != 1) {
            throw new UnsupportedOperationException("Not a time-based UUID");
        }
        return leastSigBits & 0x0000FFFFFFFFFFFFL;
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
	return Long.toString(hi | (val & (hi - 1)), 16).substring(1);
    }

    public int hashCode() {
        return (int)((mostSigBits >> 32) ^
                      mostSigBits ^
                     (leastSigBits >> 32) ^
                      leastSigBits);
    }

    public boolean equals(Object obj) {
	if (!(obj instanceof UUID))
	    return false;
        UUID id = (UUID)obj;
	return (mostSigBits == id.mostSigBits &&
                leastSigBits == id.leastSigBits);
    }

    public int compareTo(UUID val) {
        return (this.mostSigBits < val.mostSigBits ? -1 :
                (this.mostSigBits > val.mostSigBits ? 1 :
                 (this.leastSigBits < val.leastSigBits ? -1 :
                  (this.leastSigBits > val.leastSigBits ? 1 :
                   0))));
    }
}