public with sharing class ShareUtils {

    private static final Decimal ONE_CENT = 0.01;

    public static List<Decimal> calculateShares(Decimal total, Integer nShares, Integer scale) {
        List<Decimal> shares = new List<Decimal>();
        Decimal share = total.divide(nShares, scale);
        for (Integer i = 0; i < nShares; i++) {
            shares.add(share);
        }

        Decimal remainder = total - (share * nShares);

        // Distribute the remainder, that can also be negative
        for (Integer i = 0; remainder != 0; i++) {
            if (remainder > 0) {
                shares[i] += ONE_CENT;
                remainder -= ONE_CENT;
            } else if (remainder < 0) {
                shares[i] -= ONE_CENT;
                remainder += ONE_CENT;
            }
        }

        return shares;
    }

}
