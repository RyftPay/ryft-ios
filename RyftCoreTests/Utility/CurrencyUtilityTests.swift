import XCTest

@testable import RyftCore

// swiftlint:disable file_length
class CurrencyUtilityTests: XCTestCase {

    // see: https://en.wikipedia.org/wiki/ISO_4217

    func test_AED_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AED"))
    }

    func test_AFN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AFN"))
    }

    func test_ALL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ALL"))
    }

    func test_AMD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AMD"))
    }

    func test_ANG_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ANG"))
    }

    func test_AOA_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AOA"))
    }

    func test_ARS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ARS"))
    }

    func test_AUD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AUD"))
    }

    func test_AWG_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AWG"))
    }

    func test_AZN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "AZN"))
    }

    func test_BAM_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BAM"))
    }

    func test_BBD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BBD"))
    }

    func test_BDT_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BDT"))
    }

    func test_BGN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BGN"))
    }

    func test_BHD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "BHD"))
    }

    func test_BIF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "BIF"))
    }

    func test_BMD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BMD"))
    }

    func test_BND_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BND"))
    }

    func test_BOB_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BOB"))
    }

    func test_BOV_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BOV"))
    }

    func test_BRL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BRL"))
    }

    func test_BSD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BSD"))
    }

    func test_BTN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BTN"))
    }

    func test_BWP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BWP"))
    }

    func test_BYN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BYN"))
    }

    func test_BZD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "BZD"))
    }

    func test_CAD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CAD"))
    }

    func test_CDF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CDF"))
    }

    func test_CHE_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CHE"))
    }

    func test_CHF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CHF"))
    }

    func test_CHW_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CHW"))
    }

    func test_CLF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(4, CurrencyUtility.minorUnits(from: "CLF"))
    }

    func test_CLP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "CLP"))
    }

    func test_CNY_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CNY"))
    }

    func test_COP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "COP"))
    }

    func test_COU_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "COU"))
    }

    func test_CRC_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CRC"))
    }

    func test_CUC_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CUC"))
    }

    func test_CUP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CUP"))
    }

    func test_CVE_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CVE"))
    }

    func test_CZK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "CZK"))
    }

    func test_DJF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "DJF"))
    }

    func test_DKK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "DKK"))
    }

    func test_DOP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "DOP"))
    }

    func test_DZD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "DZD"))
    }

    func test_EGP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "EGP"))
    }

    func test_ERN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ERN"))
    }

    func test_ETB_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ETB"))
    }

    func test_EUR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "EUR"))
    }

    func test_FJD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "FJD"))
    }

    func test_FKP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "FKP"))
    }

    func test_GBP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GBP"))
    }

    func test_GEL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GEL"))
    }

    func test_GHS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GHS"))
    }

    func test_GIP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GIP"))
    }

    func test_GMD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GMD"))
    }

    func test_GNF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "GNF"))
    }

    func test_GTQ_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GTQ"))
    }

    func test_GYD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "GYD"))
    }

    func test_HKD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "HKD"))
    }

    func test_HNL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "HNL"))
    }

    func test_HRK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "HRK"))
    }

    func test_HTG_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "HTG"))
    }

    func test_HUF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "HUF"))
    }

    func test_IDR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "IDR"))
    }

    func test_ILS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ILS"))
    }

    func test_INR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "INR"))
    }

    func test_IQD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "IQD"))
    }

    func test_IRR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "IRR"))
    }

    func test_ISK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "ISK"))
    }

    func test_JMD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "JMD"))
    }

    func test_JOD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "JOD"))
    }

    func test_JPY_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "JPY"))
    }

    func test_KES_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "KES"))
    }

    func test_KGS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "KGS"))
    }

    func test_KHR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "KHR"))
    }

    func test_KMF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "KMF"))
    }

    func test_KPW_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "KPW"))
    }

    func test_KRW_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "KRW"))
    }

    func test_KWD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "KWD"))
    }

    func test_KYD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "KYD"))
    }

    func test_KZT_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "KZT"))
    }

    func test_LAK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "LAK"))
    }

    func test_LBP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "LBP"))
    }

    func test_LKR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "LKR"))
    }

    func test_LRD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "LRD"))
    }

    func test_LSL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "LSL"))
    }

    func test_LYD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "LYD"))
    }

    func test_MAD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MAD"))
    }

    func test_MDL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MDL"))
    }

    func test_MGA_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MGA"))
    }

    func test_MKD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MKD"))
    }

    func test_MMK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MMK"))
    }

    func test_MNT_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MNT"))
    }

    func test_MOP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MOP"))
    }

    func test_MRU_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MRU"))
    }

    func test_MUR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MUR"))
    }

    func test_MVR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MVR"))
    }

    func test_MWK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MWK"))
    }

    func test_MXN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MXN"))
    }

    func test_MXV_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MXV"))
    }

    func test_MYR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MYR"))
    }

    func test_MZN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "MZN"))
    }

    func test_NAD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "NAD"))
    }

    func test_NGN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "NGN"))
    }

    func test_NIO_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "NIO"))
    }

    func test_NOK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "NOK"))
    }

    func test_NPR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "NPR"))
    }

    func test_NZD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "NZD"))
    }

    func test_OMR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "OMR"))
    }

    func test_PAB_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "PAB"))
    }

    func test_PEN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "PEN"))
    }

    func test_PGK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "PGK"))
    }

    func test_PHP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "PHP"))
    }

    func test_PKR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "PKR"))
    }

    func test_PLN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "PLN"))
    }

    func test_PYG_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "PYG"))
    }

    func test_QAR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "QAR"))
    }

    func test_RON_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "RON"))
    }

    func test_RSD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "RSD"))
    }

    func test_RUB_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "RUB"))
    }

    func test_RWF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "RWF"))
    }

    func test_SAR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SAR"))
    }

    func test_SBD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SBD"))
    }

    func test_SCR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SCR"))
    }

    func test_SDG_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SDG"))
    }

    func test_SEK_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SEK"))
    }

    func test_SGD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SGD"))
    }

    func test_SHP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SHP"))
    }

    func test_SLL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SLL"))
    }

    func test_SOS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SOS"))
    }

    func test_SRD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SRD"))
    }

    func test_SSP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SSP"))
    }

    func test_STN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "STN"))
    }

    func test_SVC_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SVC"))
    }

    func test_SYP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SYP"))
    }

    func test_SZL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "SZL"))
    }

    func test_THB_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "THB"))
    }

    func test_TJS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TJS"))
    }

    func test_TMT_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TMT"))
    }

    func test_TND_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(3, CurrencyUtility.minorUnits(from: "TND"))
    }

    func test_TOP_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TOP"))
    }

    func test_TRY_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TRY"))
    }

    func test_TTD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TTD"))
    }

    func test_TWD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TWD"))
    }

    func test_TZS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "TZS"))
    }

    func test_UAH_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "UAH"))
    }

    func test_UGX_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "UGX"))
    }

    func test_USD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "USD"))
    }

    func test_USN_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "USN"))
    }

    func test_UYI_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "UYI"))
    }

    func test_UYU_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "UYU"))
    }

    func test_UYW_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(4, CurrencyUtility.minorUnits(from: "UYW"))
    }

    func test_UZS_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "UZS"))
    }

    func test_VED_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "VED"))
    }

    func test_VES_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "VES"))
    }

    func test_VND_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "VND"))
    }

    func test_VUV_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "VUV"))
    }

    func test_WST_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "WST"))
    }

    func test_XAF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "XAF"))
    }

    func test_XCD_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "XCD"))
    }

    func test_XOF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "XOF"))
    }

    func test_XPF_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(0, CurrencyUtility.minorUnits(from: "XPF"))
    }

    func test_YER_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "YER"))
    }

    func test_ZAR_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ZAR"))
    }

    func test_ZMW_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ZMW"))
    }

    func test_ZWL_shouldReturnExpectedMinorUnits() {
        XCTAssertEqual(2, CurrencyUtility.minorUnits(from: "ZWL"))
    }
}
// swiftlint:enable file_length
