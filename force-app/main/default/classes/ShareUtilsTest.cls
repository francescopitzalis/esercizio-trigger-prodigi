@IsTest
private class ShareUtilsTest {

    private class CalculateSharesTest {

        private Decimal total;
        private Integer nShares;
        private List<Decimal> expectedShares;

        private CalculateSharesTest total(Decimal total) {
            this.total = total;
            return this;
        }

        private CalculateSharesTest nShares(Integer nShares) {
            this.nShares = nShares;
            return this;
        }

        private CalculateSharesTest expectedShares(List<Decimal> expectedShares) {
            this.expectedShares = expectedShares;
            return this;
        }

        private void run() {
            List<Decimal> actualShares = ShareUtils.calculateShares(total, nShares, 2);

            System.debug('actualShares: ' + actualShares);
            System.debug('expectedShares: ' + expectedShares);

            for (Decimal actualShare : actualShares) {
                Integer shareIndex = expectedShares.indexOf(actualShare);
                System.assertNotEquals(-1, shareIndex);
                expectedShares.remove(shareIndex);
            }
        }
    }

    @IsTest
    static void calculateShares_remainderZero() {
        new CalculateSharesTest()
            .total(100)
            .nShares(4)
            .expectedShares(new Decimal[] {25.00, 25.00, 25.00, 25.00})
            .run();
    }

    @IsTest
    static void calculateShares_remainderOneCent() {
        new CalculateSharesTest()
            .total(100)
            .nShares(3)
            .expectedShares(new Decimal[] {33.34, 33.33, 33.33})
            .run();
    }

    @IsTest
    static void calculateShares_remainderTwoCents() {
        new CalculateSharesTest()
            .total(200)
            .nShares(11)
            .expectedShares(new Decimal[] {18.19, 18.19, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18, 18.18})
            .run();
    }

    @IsTest
    static void calculateShares_remainderThreeCents() {
        new CalculateSharesTest()
            .total(100)
            .nShares(13)
            .expectedShares(new Decimal[] {7.70, 7.70, 7.70, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69, 7.69})
            .run();
    }

    @IsTest
    static void calculateShares_remainderMinusOneCent() {
        new CalculateSharesTest()
            .total(200)
            .nShares(3)
            .expectedShares(new Decimal[] {66.66, 66.67, 66.67})
            .run();
    }

    @IsTest
    static void calculateShares_remainderMinusTwoCents() {
        new CalculateSharesTest()
            .total(100)
            .nShares(6)
            .expectedShares(new Decimal[] {16.66, 16.66, 16.67, 16.67, 16.67, 16.67})
            .run();
    }

    @IsTest
    static void calculateShares_remainderMinusThreeCents() {
        new CalculateSharesTest()
            .total(100)
            .nShares(7)
            .expectedShares(new Decimal[] {14.28, 14.28, 14.28, 14.29, 14.29, 14.29, 14.29})
            .run();
    }
}
