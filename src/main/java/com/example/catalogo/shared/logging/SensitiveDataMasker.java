package com.example.catalogo.shared.logging;

public final class SensitiveDataMasker {

    private SensitiveDataMasker() {
    }

    public static String maskCnpj(String cnpj) {
        if (cnpj == null || cnpj.length() < 8) {
            return "***";
        }
        String digits = cnpj.replaceAll("\\D", "");
        if (digits.length() != 14) {
            return "***INVALID***";
        }
        return digits.substring(0, 2) + ".***.***/" + digits.substring(8, 12) + "-**";
    }

    public static String maskPhone(String phone) {
        if (phone == null || phone.length() < 4) {
            return "***";
        }
        String digits = phone.replaceAll("\\D", "");
        if (digits.length() < 10) {
            return "***INVALID***";
        }
        return "(***) ***-*" + digits.substring(digits.length() - 4);
    }

    public static String maskPatientName(String name) {
        return "[REDACTED]";
    }
}
