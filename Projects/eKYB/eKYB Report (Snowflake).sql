with ekyb_all as (WITH EKYB AS (WITH EXTERNAL_ID_CHECK AS (SELECT KYC.MERCHANT_ID,
                                                           KYC.ACTION_TIME,
                                                           CASE
                                                               WHEN KYC_ACTION_ID = 1249 THEN TRUE
                                                               ELSE FALSE
                                                               END  AS platform_externalIdChecked,
                                                           KAS.NAME AS EXTERNAL_ID_CHECK
                                                    FROM SRC_PAYMENT.KYC_LOGS KYC
                                                             LEFT JOIN SRC_PAYMENT.KYC_ACTION_STATUSES KAS
                                                                       ON KYC.KYC_ACTION_STATUS_ID = KAS.ID
                                                    WHERE KYC.KYC_ACTION_ID in (82, 1249)
                                                        QUALIFY ROW_NUMBER() OVER (PARTITION BY KYC.MERCHANT_ID ORDER BY KYC.ACTION_TIME DESC ) =
                                                                1),

                              ONFIDO AS (SELECT MERCHANT_ID,
                                                CREATED_AT,
                                                STATUS
                                         FROM SRC_PAYMENT.MERCHANT_ID_VERIFICATIONS
                                         WHERE COMPLETE = TRUE
                                             QUALIFY ROW_NUMBER() OVER (PARTITION BY MERCHANT_ID ORDER BY CREATED_AT DESC ) = 1),

                              ONBOARDING_REVIEW AS (SELECT MERCHANT_ID,
                                                           COUNT(CASE WHEN KYC_ACTION_ID IN (59, 60) THEN 1 END) AS ONBOARDING_REVIEW_COUNT
                                                    FROM SRC_PAYMENT.KYC_LOGS
                                                    GROUP BY 1)

                         SELECT KYC.MERCHANT_ID          as "merchant_id",
                                M.DIM_MERCHANT_ID,
                                M.MERCHANT_CODE          as "merchant_code",
                                MAS.ACCOUNT_STATUS       as "account_status",
                                MAS.ACCOUNT_SUBSTATUS    as "account_substatus",
                                TPV.TPV_TOTAL_EUR,
                                TPV.TPV_365_DAYS_EUR,
                                TPV.TPV_60_DAYS_EUR,
                                TPV.TPV_30_DAYS_EUR,
                                TPV.TPV_7_DAYS_EUR,
                                M.SIGNUP_DATE            AS "signup_time",
                                KYC.SRC_CREATED_AT       AS "verification_time",
                                KAS.NAME                 AS "company_identity_check",
                                EKYC.EXTERNAL_ID_CHECK   AS "external_id_check",
                                ONFIDO.STATUS            AS "onfido",
                                CASE
                                    WHEN ONBOARDING_REVIEW_COUNT = 0 OR ONBOARDING_REVIEW_COUNT = NULL THEN 'No'
                                    ELSE 'Yes'
                                    END                  AS "onboarding_review",
                                KYC.COMMENT              AS "comment",
                                M.REGULATORY_ENVIRONMENT AS "license",
                                M.MERCHANT_GLOBAL_REGION AS "merchant_region",
                                M.MERCHANT_COUNTRY       AS "merchant_country",
                                M.LEGAL_TYPE             AS "long_legal_type",
                                M.MCC_LEVEL              AS "mcc",
                                CASE
                                    WHEN KYC.KYC_ACTION_ID = 1248 THEN TRUE
                                    ELSE FALSE
                                    END                  AS platform_companyIdentityCheck,
                                platform_externalIdChecked
                         FROM SRC_PAYMENT.KYC_LOGS KYC
                                  LEFT JOIN SRC_PAYMENT.KYC_ACTION_STATUSES KAS ON KYC.KYC_ACTION_STATUS_ID = KAS.ID
                                  LEFT JOIN OLAP.V_M_DIM_MERCHANT M ON KYC.MERCHANT_ID = M.MERCHANT_ID
                                  LEFT JOIN OLAP.V_M_DIM_ACCOUNT_STATUS MAS ON M.DIM_MERCHANT_ID = MAS.DIM_MERCHANT_ID
                                  LEFT JOIN EXTERNAL_ID_CHECK EKYC ON EKYC.MERCHANT_ID = KYC.MERCHANT_ID
                                  LEFT JOIN ONFIDO ON ONFIDO.MERCHANT_ID = KYC.MERCHANT_ID
                                  LEFT JOIN ONBOARDING_REVIEW ON ONBOARDING_REVIEW.MERCHANT_ID = KYC.MERCHANT_ID
                                  LEFT JOIN OLAP.V_M_FACTS_TRANSACTION TPV ON M.DIM_MERCHANT_ID = TPV.DIM_MERCHANT_ID
                         WHERE KYC.KYC_ACTION_ID in (1245, 1248)
                           AND M.IS_COMPANY = TRUE
                           AND M.IS_TEST = FALSE
                           AND KYC.ACTION_TIME >= '2018-01-01'
                           AND M.MERCHANT_COUNTRY IN ('GB', 'BR', 'FR', 'IT', 'DE')
                             QUALIFY ROW_NUMBER() OVER (PARTITION BY KYC.MERCHANT_ID ORDER BY KYC.ACTION_TIME DESC ) =
                                     1)

           SELECT EKYB.*,
                  'nationality_match' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE '%nationality_matches"=>true%' OR
                            EKYB."comment" ILIKE '%nationality_matches"=>"yes%' OR
                            EKYB."comment" ILIKE '%"NationalityCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE '%nationality_matches"=>false%' OR
                            EKYB."comment" ILIKE '%nationality_matches"=>"no"%' OR
                            EKYB."comment" ILIKE '%"NationalityCheck"=>"fail"')
                          THEN 'false'
                      ELSE 'not_applicable'
                      END             AS "subcehck_result",
                  'company'           as legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'name_match' AS "subcheck_type",
                  CASE
                      WHEN
                          (EKYB."comment" ILIKE '%name_matches"=>true%' OR
                           EKYB."comment" ILIKE '%name_matches"=>"yes"%' OR
                           EKYB."comment" ILIKE '%"NameCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE '%name_matches"=>false%' OR
                            EKYB."comment" ILIKE '%name_matches"=>"no"%' OR
                            EKYB."comment" ILIKE '%"NameCheck"=>"fail"%')
                          THEN 'false'
                      ELSE 'not_applicable'
                      END      AS "subcheck_result",
                  'company'    as legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'address_match' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE '%address_matches"=>true%' OR
                            EKYB."comment" ILIKE '%address_matches"=>"yes"%' OR
                            EKYB."comment" ILIKE '%"AddressCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE '%address_matches"=>false%' OR
                            EKYB."comment" ILIKE '%address_matches"=>"no"%' OR
                            EKYB."comment" ILIKE '%"AddressCheck"=>"fail"%')
                          THEN 'false'
                      ELSE 'not_applicable'
                      END         AS "subcheck_result",
                  'company'       AS legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'legal_match' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE
                            '%legal_type_matches"=>true%' OR
                            EKYB."comment" ILIKE
                            '%legal_type_matches"=>"yes"%' OR
                            EKYB."comment" ILIKE '%"LegalTypeCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE
                            '%legal_type_matches"=>false%' OR
                            EKYB."comment" ILIKE
                            '%legal_type_matches"=>"no"%' OR
                            EKYB."comment" ILIKE '%"LegalTypeCheck"=>"fail"%')
                          then 'false'
                      ELSE 'not_applicable'
                      END       AS "subcheck_result",
                  'company'     AS legal_type

           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'register_match' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE '%registered_status"=>true%' OR
                            EKYB."comment" ILIKE
                            '%registered_status"=>"yes"%' OR
                            EKYB."comment" ILIKE '%"StatusCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE
                            '%registered_status"=>false%' OR
                            EKYB."comment" ILIKE '%registered_status"=>"no"%' OR
                            EKYB."comment" ILIKE '%"StatusCheck"=>"fail"%')
                          THEN 'false'
                      ELSE 'not_applicable'
                      END          AS "subcheck_result",
                  'company'        AS legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'not_in_blocklist' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE '%not_in_blacklist"=>true%' OR
                            EKYB."comment" ILIKE
                            '%economic_activity_allowed"=>"yes%' OR
                            EKYB."comment" ILIKE
                            '%"NatureAndPurposeCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE '%not_in_blacklist"=>false%' OR
                            EKYB."comment" ILIKE
                            '%economic_activity_allowed"=>"no%' OR
                            EKYB."comment" ILIKE
                            '%"NatureAndPurposeCheck"=>"fail"%')
                          THEN 'false'
                      ELSE 'not_applicable'
                      END            AS "subcheck_result",
                  'company'          AS legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'ubo_is_primary' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE
                            '%primary_contact_is_ubo"=>true%' OR
                            EKYB."comment" ILIKE '%"merchant_is_ubo"=>"yes"%' OR
                            EKYB."comment" ILIKE
                            '%PrimaryContactAuthorityCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE
                            '%primary_contact_is_ubo"=>false%' OR
                            EKYB."comment" ILIKE '%"merchant_is_ubo"=>"no"%' OR
                            EKYB."comment" ILIKE
                            '%PrimaryContactAuthorityCheck"=>"fail"%'
                          ) THEN 'false'
                      ELSE 'not_applicable'
                      END          AS "subcheck_result",
                  'company'        AS legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'ubos_match' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ILIKE '%ubos_match"=>true%' OR
                            EKYB."comment" ILIKE '%ubos_match"=>"yes"%' OR
                            EKYB."comment" ILIKE '%"UboComparisonCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ILIKE '%ubos_match"=>"false"%' OR
                            EKYB."comment" ILIKE '%ubos_match"=>"no"%' OR
                            EKYB."comment" ILIKE '%"UboComparisonCheck"=>"fail"%')
                          THEN 'false'
                      ELSE 'not_applicable'
                      END      AS "subcheck_result",
                  'company'    AS legal_type
           FROM EKYB
           UNION ALL
           SELECT EKYB.*,
                  'ubo_is_company' AS "subcheck_type",
                  CASE
                      WHEN (EKYB."comment" ilike '%"UboIsCompanyCheck"=>"pass"%')
                          THEN 'true'
                      WHEN (EKYB."comment" ilike '%"UboIsCompanyCheck"=>"fail"%')
                          THEN 'false'
                      ELSE 'not_applicable'
                      end          as "subcheck_result",
                  'company'        AS legal_type
           FROM EKYB)

select *,
       ROW_NUMBER()OVER (PARTITION BY "merchant_code", "verification_time" order by "subcheck_type" asc ) as subcheck_no
from ekyb_all
order by "merchant_id"
