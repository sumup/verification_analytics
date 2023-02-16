
CREATE
    OR
    REPLACE
    TABLE ANALYST_PAYMENTS.ONFIDO_REPORT_DOCUMENTS
(
    ID                                            INTEGER PRIMARY KEY AUTOINCREMENT START 1 INCREMENT 1,
    EID_CHECK_ID                                  INTEGER,
    CREATED_AT                                    TIMESTAMP,
    UPDATED_AT                                    TIMESTAMP,
    MERCHANT_ID                                   INTEGER,
    COMPLETE                                      BOOLEAN,
    STATUS                                        VARCHAR,
    CHECK_TYPE                                    VARCHAR,
    GENERAL_RESULT                                VARCHAR,
    GENERAL_SUB_RESULT                            VARCHAR,
    VARIANT                                       VARCHAR,
    DOCUMENT_TYPE                                 VARCHAR,
    DOCUMENT_DATE_OF_EXPIRY                       VARCHAR,
    DOCUMENT_ISSUING_COUNTRY                      VARCHAR,
    MERCHANT_NATIONALITY                          VARCHAR,
    GENERAL_AGE_VALIDATION                        VARCHAR,
    GENERAL_POLICE_RECORD                         VARCHAR,
    GENERAL_COMPROMISED_DOCUMENT                  VARCHAR,
    GENERAL_DATA_COMPARISON                       VARCHAR,
    COMPARISON_DATE_OF_BIRTH                      VARCHAR,
    COMPARISON_DATE_OF_EXPIRY                     VARCHAR,
    COMPARISON_DOCUMENT_NUMBERS                   VARCHAR,
    COMPARISON_FIRST_NAME                         VARCHAR,
    COMPARISON_LAST_NAME                          VARCHAR,
    COMPARISON_GENDER                             VARCHAR,
    COMPARISON_ISSUING_COUNTRY                    VARCHAR,
    GENERAL_DATA_CONSISTENCY                      VARCHAR,
    CONSISTENCY_DATE_OF_BIRTH                     VARCHAR,
    CONSISTENCY_DATE_OF_EXPIRY                    VARCHAR,
    CONSISTENCY_DOCUMENT_NUMBERS                  VARCHAR,
    CONSISTENCY_DOCUMENT_TYPE                     VARCHAR,
    CONSISTENCY_FIRST_NAME                        VARCHAR,
    CONSISTENCY_LAST_NAME                         VARCHAR,
    CONSISTENCY_GENDER                            VARCHAR,
    CONSISTENCY_ISSUING_COUNTRY                   VARCHAR,
    CONSISTENCY_NATIONALITY                       VARCHAR,
    GENERAL_DATA_VALIDATION                       VARCHAR,
    VALIDATION_DATE_OF_BIRTH                      VARCHAR,
    VALIDATION_DOCUMENT_EXPIRATION                VARCHAR,
    VALIDATION_DOCUMENT_NUMBERS                   VARCHAR,
    VALIDATION_EXPIRY_DATE                        VARCHAR,
    VALIDATION_GENDER                             VARCHAR,
    VALIDATION_MRZ                                VARCHAR,
    GENERAL_IMAGE_INTEGRITY                       VARCHAR,
    IMAGE_INTEGRITY_COLOR_PICTURE                 VARCHAR,
    IMAGE_INTEGRITY_CONCLUSIVE_DOCUMENT_QUALITY   VARCHAR,
    CDQ_ABNORMAL_DOCUMENT_FEATURES                VARCHAR,
    CDQ_CORNER_REMOVED                            VARCHAR,
    CDQ_DIGITAL_DOCUMENT                          VARCHAR,
    CDQ_MISSING_BACK                              VARCHAR,
    CDQ_OBSCURED_DATA_POINTS                      VARCHAR,
    CDQ_PUNCTURED_DOCUMENT                        VARCHAR,
    CDQ_WATERMARKS                                VARCHAR,
    IMAGE_INTEGRITY_IMAGE_QUALITY                 VARCHAR,
    IMAGE_QUALITY_BLURRED_PHOTO                   VARCHAR,
    IMAGE_QUALITY_GLARE_ON_PHOTO                  VARCHAR,
    IMAGE_QUALITY_DARK_PHOTO                      VARCHAR,
    IMAGE_QUALITY_COVERED_PHOTO                   VARCHAR,
    IMAGE_QUALITY_OTHER_PHOTO_ISSUE               VARCHAR,
    IMAGE_QUALITY_DAMAGED_DOCUMENT                VARCHAR,
    IMAGE_QUALITY_INCORRECT_SIDE                  VARCHAR,
    IMAGE_QUALITY_CUT_OFF_DOCUMENT                VARCHAR,
    IMAGE_QUALITY_NO_DOCUMENT_IN_IMAGE            VARCHAR,
    IMAGE_QUALITY_TWO_DOCUMENTS_UPLOADED          VARCHAR,
    IMAGE_INTEGRITY_SUPPORTED_DOCUMENT            VARCHAR,
    GENERAL_VISUAL_AUTHENTICITY                   VARCHAR,
    VISUAL_AUTHENTICITY_FACE_DETECTION            VARCHAR,
    VISUAL_AUTHENTICITY_FONTS                     VARCHAR,
    VISUAL_AUTHENTICITY_ORIGINAL_DOCUMENT_PRESENT VARCHAR,
    ODP_PRINTED_ON_PAPER                          VARCHAR,
    ODP_PHOTO_OF_SCREEN                           VARCHAR,
    ODP_SCAN                                      VARCHAR,
    ODP_SCREENSHOT                                VARCHAR,
    VISUAL_AUTHENTICITY_OTHER                     VARCHAR,
    VISUAL_AUTHENTICITY_PICTURE_FACE_INTEGRITY    VARCHAR,
    VISUAL_AUTHENTICITY_SECURITY_FEATURES         VARCHAR,
    VISUAL_AUTHENTICITY_TEMPLATE                  VARCHAR,
    POST_PROCESSING_COMMENT                       TEXT,
    JSON_BODY_INDEX                               INTEGER
);


CREATE
    OR
    REPLACE
    TASK ANALYST_PAYMENTS.INSERT_ONFIDO_REPORT_DOCUMENT
    WAREHOUSE = ANALYTICS_WH
    SCHEDULE = 'USING CRON 0 1 * * * Europe/Sofia'
    TIMESTAMP_INPUT_FORMAT = 'YYYY-MM-DD HH24'
    AS
        MERGE INTO ANALYST_PAYMENTS.ONFIDO_REPORT_DOCUMENTS ODC
            USING (SELECT ONFIDO.ID                                                                                                                     AS EID_CHECK_ID
                        , ONFIDO.SRC_CREATED_AT                                                                                                         AS CREATED_AT
                        , ONFIDO.SRC_UPDATED_AT                                                                                                         AS UPDATED_AT
                        , ONFIDO.MERCHANT_ID
                        , COMPLETE
                        , STATUS
                        , D.VALUE:body: name::TEXT                                                                                                      AS CHECK_TYPE
                        , D.VALUE:body: result::TEXT                                                                                                    AS GENERAL_RESULT
                        , D.VALUE:body:sub_result::TEXT                                                                                                 AS GENERAL_SUB_RESULT
                        , D.VALUE:body: variant::TEXT                                                                                                   AS VARIANT
                        , D.VALUE:body:properties:document_type::TEXT                                                                                   AS DOCUMENT_TYPE
                        , D.VALUE:body:properties:date_of_expiry::TEXT                                                                                  AS DOCUMENT_DATE_OF_EXPIRY
                        , D.VALUE:body:properties:issuing_country::TEXT                                                                                 AS DOCUMENT_ISSUING_COUNTRY
                        , D.VALUE:body:properties:nationality::TEXT                                                                                     AS MERCHANT_NATIONALITY
                        , D.VALUE:body:breakdown:age_validation: result::TEXT                                                                           AS general_age_validation
                        , D.VALUE:body:breakdown:police_record: result::TEXT                                                                            AS general_police_record
                        , D.VALUE:body:breakdown:compromised_document: result::TEXT                                                                     AS general_compromised_document
                        , D.VALUE:body:breakdown:data_comparison: result::TEXT                                                                          AS general_data_comparison
                        , D.VALUE:body:breakdown:data_comparison:breakdown:date_of_birth: result::TEXT                                                  AS comparison_date_of_birth
                        , D.VALUE:body:breakdown:data_comparison:breakdown:date_of_expiry: result::TEXT                                                 AS comparison_date_of_expiry
                        , D.VALUE:body:breakdown:data_comparison:breakdown:document_numbers: result::TEXT                                               AS comparison_document_numbers
                        , D.VALUE:body:breakdown:data_comparison:breakdown:document_type: result::TEXT                                                  AS comparison_document_type
                        , D.VALUE:body:breakdown:data_comparison:breakdown: first_name: result::TEXT                                                    AS comparison_first_name
                        , D.VALUE:body:breakdown:data_comparison:breakdown: last_name: result::TEXT                                                     AS comparison_last_name
                        , D.VALUE:body:breakdown:data_comparison:breakdown:gender: result::TEXT                                                         AS comparison_gender
                        , D.VALUE:body:breakdown:data_comparison:breakdown:issuing_country: result::TEXT                                                AS comparison_issuing_country
                        , D.VALUE:body:breakdown:data_consistency: result::TEXT                                                                         AS general_data_consistency
                        , D.VALUE:body:breakdown:data_consistency:breakdown:date_of_birth: result::TEXT                                                 AS consistency_date_of_birth
                        , D.VALUE:body:breakdown:data_consistency:breakdown:date_of_expiry: result::TEXT                                                AS consistency_date_of_expiry
                        , D.VALUE:body:breakdown:data_consistency:breakdown:document_numbers: result::TEXT                                              AS consistency_document_numbers
                        , D.VALUE:body:breakdown:data_consistency:breakdown:document_type: result::TEXT                                                 AS consistency_document_type
                        , D.VALUE:body:breakdown:data_consistency:breakdown: first_name: result::TEXT                                                   AS consistency_first_name
                        , D.VALUE:body:breakdown:data_consistency:breakdown: last_name: result::TEXT                                                    AS consistency_last_name
                        , D.VALUE:body:breakdown:data_consistency:breakdown:gender: result::TEXT                                                        AS consistency_gender
                        , D.VALUE:body:breakdown:data_consistency:breakdown:issuing_country: result::TEXT                                               AS consistency_issuing_country
                        , D.VALUE:body:breakdown:data_consistency:breakdown:nationality: result::TEXT                                                   AS consistency_nationality
                        , D.VALUE:body:breakdown:data_validation: result::TEXT                                                                          AS general_data_validation
                        , D.VALUE:body:breakdown:data_validation:breakdown:date_of_birth: result::TEXT                                                  AS validation_date_of_birth
                        , D.VALUE:body:breakdown:data_validation:breakdown:document_expiration: result::TEXT                                            AS validation_document_expiration
                        , D.VALUE:body:breakdown:data_validation:breakdown:document_numbers: result::TEXT                                               AS validation_document_numbers
                        , D.VALUE:body:breakdown:data_validation:breakdown:expiry_date: result::TEXT                                                    AS validation_expiry_date
                        , D.VALUE:body:breakdown:data_validation:breakdown:gender: result::TEXT                                                         AS validation_gender
                        , D.VALUE:body:breakdown:data_validation:breakdown:mrz: result::TEXT                                                            AS validation_mrz
                        , D.VALUE:body:breakdown:image_integrity: result::TEXT                                                                          AS general_image_integrity
                        , D.VALUE:body:breakdown:image_integrity:breakdown:colour_picture: result::TEXT                                                 AS image_integrity_color_picture
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality: result::TEXT                                    AS image_integrity_conclusive_document_quality
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:abnormal_document_features::TEXT      AS cdq_abnormal_document_features
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:corner_removed::TEXT                  AS cdq_corner_removed
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:digital_document::TEXT                AS cdq_digital_document
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:missing_back::TEXT                    AS cdq_missing_back
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:obscured_data_points::TEXT            AS cdq_obscured_data_points
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:punctured_document::TEXT              AS cdq_punctured_document
                        , D.VALUE:body:breakdown:image_integrity:breakdown:conclusive_document_quality:properties:watermarks_digital_text_overlay::TEXT AS cdq_watermarks
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality: result::TEXT                                                  AS image_integrity_image_quality
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:blurred_photo::TEXT                                 AS image_quality_blurred_photo
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:glare_on_photo::TEXT                                AS image_quality_glare_on_photo
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:dark_photo::TEXT                                    AS image_quality_dark_photo
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:covered_photo::TEXT                                 AS image_quality_covered_photo
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:other_photo_issue::TEXT                             AS image_quality_other_photo_issue
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:damaged_document::TEXT                              AS IMAGE_QUALITY_DAMAGED_DOCUMENT
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:incorrect_side::TEXT                                AS image_quality_incorrect_side
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:cut_off_document::TEXT                              AS image_quality_cut_off_document
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:no_document_in_image::TEXT                          AS image_quality_no_document_in_image
                        , D.VALUE:body:breakdown:image_integrity:breakdown:image_quality:properties:two_documents_uploaded::TEXT                        as image_quality_two_documents_uploaded
                        , D.VALUE:body:breakdown:image_integrity:breakdown:supported_document: result::TEXT                                             AS image_integrity_supported_document
                        , D.VALUE:body:breakdown:visual_authenticity: result::TEXT                                                                      AS general_visual_authenticity
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:digital_tampering: result::TEXT                                          AS visual_authenticity_digital_tampering
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:face_detection: result::TEXT                                             AS VISUAL_AUTHENTICITY_FACE_DETECTION
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:fonts: result::TEXT                                                      AS visual_authenticity_fonts
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:original_document_present: result::TEXT                                  AS visual_authenticity_original_document_present
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:original_document_present:properties:document_on_printed_paper::TEXT     AS odp_printed_on_paper
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:original_document_present:properties:photo_of_screen::TEXT               AS odp_photo_of_screen
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:original_document_present:properties:scan::TEXT                          AS odp_scan
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:original_document_present:properties:screenshot::TEXT                    AS odp_screenshot
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:other: result::TEXT                                                      AS visual_authenticity_other
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:picture_face_integrity: result::TEXT                                     AS visual_authenticity_picture_face_integrity
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:security_features: result::TEXT                                          AS VISUAL_AUTHENTICITY_SECURITY_FEATURES
                        , D.VALUE:body:breakdown:visual_authenticity:breakdown:template: result::TEXT                                                   AS visual_authenticity_template
                        , CASE
                              WHEN D.VALUE: comment::TEXT ILIKE '%national id%' and
                                   D.VALUE: comment::TEXT ILIKE '%does not match%' THEN 'National ID does not match'
                              ELSE D.VALUE: comment::TEXT END                                                                                           AS POST_PROCESSING_COMMENT
                        , D.INDEX                                                                                                                       AS json_body_index
                        , PARSE_JSON(ONFIDO.DATA)                                                                                                       AS json_data
                   FROM SRC_PAYMENT.MERCHANT_ID_VERIFICATIONS ONFIDO,
                        TABLE ( FLATTEN(PARSE_JSON(data):states)) D
                   WHERE D.VALUE: type::TEXT = 'report'
                     AND D.VALUE:body: name::TEXT = 'document'
                       QUALIFY ROW_NUMBER() OVER (PARTITION BY ONFIDO.ID ORDER BY D.INDEX DESC ) = 1
            ) NEW ON ODC.EID_CHECK_ID = NEW.EID_CHECK_ID
            WHEN NOT MATCHED THEN
                INSERT (
                        EID_CHECK_ID,
                        CREATED_AT,
                        UPDATED_AT,
                        MERCHANT_ID,
                        COMPLETE,
                        STATUS,
                        CHECK_TYPE,
                        GENERAL_RESULT,
                        GENERAL_SUB_RESULT,
                        VARIANT,
                        DOCUMENT_TYPE,
                        DOCUMENT_DATE_OF_EXPIRY,
                        DOCUMENT_ISSUING_COUNTRY,
                        MERCHANT_NATIONALITY,
                        GENERAL_AGE_VALIDATION,
                        GENERAL_POLICE_RECORD,
                        GENERAL_COMPROMISED_DOCUMENT,
                        GENERAL_DATA_COMPARISON,
                        COMPARISON_DATE_OF_BIRTH,
                        COMPARISON_DATE_OF_EXPIRY,
                        COMPARISON_DOCUMENT_NUMBERS,
                        COMPARISON_FIRST_NAME,
                        COMPARISON_LAST_NAME,
                        COMPARISON_GENDER,
                        COMPARISON_ISSUING_COUNTRY,
                        GENERAL_DATA_CONSISTENCY,
                        CONSISTENCY_DATE_OF_BIRTH,
                        CONSISTENCY_DATE_OF_EXPIRY,
                        CONSISTENCY_DOCUMENT_NUMBERS,
                        CONSISTENCY_DOCUMENT_TYPE,
                        CONSISTENCY_FIRST_NAME,
                        CONSISTENCY_LAST_NAME,
                        CONSISTENCY_GENDER,
                        CONSISTENCY_ISSUING_COUNTRY,
                        CONSISTENCY_NATIONALITY,
                        GENERAL_DATA_VALIDATION,
                        VALIDATION_DATE_OF_BIRTH,
                        VALIDATION_DOCUMENT_EXPIRATION,
                        VALIDATION_DOCUMENT_NUMBERS,
                        VALIDATION_EXPIRY_DATE,
                        VALIDATION_GENDER,
                        VALIDATION_MRZ,
                        GENERAL_IMAGE_INTEGRITY,
                        IMAGE_INTEGRITY_COLOR_PICTURE,
                        IMAGE_INTEGRITY_CONCLUSIVE_DOCUMENT_QUALITY,
                        CDQ_ABNORMAL_DOCUMENT_FEATURES,
                        CDQ_CORNER_REMOVED,
                        CDQ_DIGITAL_DOCUMENT,
                        CDQ_MISSING_BACK,
                        CDQ_OBSCURED_DATA_POINTS,
                        CDQ_PUNCTURED_DOCUMENT,
                        CDQ_WATERMARKS,
                        IMAGE_INTEGRITY_IMAGE_QUALITY,
                        IMAGE_QUALITY_BLURRED_PHOTO,
                        IMAGE_QUALITY_GLARE_ON_PHOTO,
                        IMAGE_QUALITY_DARK_PHOTO,
                        IMAGE_QUALITY_COVERED_PHOTO,
                        IMAGE_QUALITY_OTHER_PHOTO_ISSUE,
                        IMAGE_QUALITY_DAMAGED_DOCUMENT,
                        IMAGE_QUALITY_INCORRECT_SIDE,
                        IMAGE_QUALITY_CUT_OFF_DOCUMENT,
                        IMAGE_QUALITY_NO_DOCUMENT_IN_IMAGE,
                        IMAGE_QUALITY_TWO_DOCUMENTS_UPLOADED,
                        IMAGE_INTEGRITY_SUPPORTED_DOCUMENT,
                        GENERAL_VISUAL_AUTHENTICITY,
                        VISUAL_AUTHENTICITY_FACE_DETECTION,
                        VISUAL_AUTHENTICITY_FONTS,
                        VISUAL_AUTHENTICITY_ORIGINAL_DOCUMENT_PRESENT,
                        ODP_PRINTED_ON_PAPER,
                        ODP_PHOTO_OF_SCREEN,
                        ODP_SCAN,
                        ODP_SCREENSHOT,
                        VISUAL_AUTHENTICITY_OTHER,
                        VISUAL_AUTHENTICITY_PICTURE_FACE_INTEGRITY,
                        VISUAL_AUTHENTICITY_SECURITY_FEATURES,
                        VISUAL_AUTHENTICITY_TEMPLATE,
                        POST_PROCESSING_COMMENT,
                        JSON_BODY_INDEX)

                    VALUES (
                            EID_CHECK_ID,
                            CREATED_AT,
                            UPDATED_AT,
                            MERCHANT_ID,
                            COMPLETE,
                            STATUS,
                            CHECK_TYPE,
                            GENERAL_RESULT,
                            GENERAL_SUB_RESULT,
                            VARIANT,
                            DOCUMENT_TYPE,
                            DOCUMENT_DATE_OF_EXPIRY,
                            DOCUMENT_ISSUING_COUNTRY,
                            MERCHANT_NATIONALITY,
                            GENERAL_AGE_VALIDATION,
                            GENERAL_POLICE_RECORD,
                            GENERAL_COMPROMISED_DOCUMENT,
                            GENERAL_DATA_COMPARISON,
                            COMPARISON_DATE_OF_BIRTH,
                            COMPARISON_DATE_OF_EXPIRY,
                            COMPARISON_DOCUMENT_NUMBERS,
                            COMPARISON_FIRST_NAME,
                            COMPARISON_LAST_NAME,
                            COMPARISON_GENDER,
                            COMPARISON_ISSUING_COUNTRY,
                            GENERAL_DATA_CONSISTENCY,
                            CONSISTENCY_DATE_OF_BIRTH,
                            CONSISTENCY_DATE_OF_EXPIRY,
                            CONSISTENCY_DOCUMENT_NUMBERS,
                            CONSISTENCY_DOCUMENT_TYPE,
                            CONSISTENCY_FIRST_NAME,
                            CONSISTENCY_LAST_NAME,
                            CONSISTENCY_GENDER,
                            CONSISTENCY_ISSUING_COUNTRY,
                            CONSISTENCY_NATIONALITY,
                            GENERAL_DATA_VALIDATION,
                            VALIDATION_DATE_OF_BIRTH,
                            VALIDATION_DOCUMENT_EXPIRATION,
                            VALIDATION_DOCUMENT_NUMBERS,
                            VALIDATION_EXPIRY_DATE,
                            VALIDATION_GENDER,
                            VALIDATION_MRZ,
                            GENERAL_IMAGE_INTEGRITY,
                            IMAGE_INTEGRITY_COLOR_PICTURE,
                            IMAGE_INTEGRITY_CONCLUSIVE_DOCUMENT_QUALITY,
                            CDQ_ABNORMAL_DOCUMENT_FEATURES,
                            CDQ_CORNER_REMOVED,
                            CDQ_DIGITAL_DOCUMENT,
                            CDQ_MISSING_BACK,
                            CDQ_OBSCURED_DATA_POINTS,
                            CDQ_PUNCTURED_DOCUMENT,
                            CDQ_WATERMARKS,
                            IMAGE_INTEGRITY_IMAGE_QUALITY,
                            IMAGE_QUALITY_BLURRED_PHOTO,
                            IMAGE_QUALITY_GLARE_ON_PHOTO,
                            IMAGE_QUALITY_DARK_PHOTO,
                            IMAGE_QUALITY_COVERED_PHOTO,
                            IMAGE_QUALITY_OTHER_PHOTO_ISSUE,
                            IMAGE_QUALITY_DAMAGED_DOCUMENT,
                            IMAGE_QUALITY_INCORRECT_SIDE,
                            IMAGE_QUALITY_CUT_OFF_DOCUMENT,
                            IMAGE_QUALITY_NO_DOCUMENT_IN_IMAGE,
                            IMAGE_QUALITY_TWO_DOCUMENTS_UPLOADED,
                            IMAGE_INTEGRITY_SUPPORTED_DOCUMENT,
                            GENERAL_VISUAL_AUTHENTICITY,
                            VISUAL_AUTHENTICITY_FACE_DETECTION,
                            VISUAL_AUTHENTICITY_FONTS,
                            VISUAL_AUTHENTICITY_ORIGINAL_DOCUMENT_PRESENT,
                            ODP_PRINTED_ON_PAPER,
                            ODP_PHOTO_OF_SCREEN,
                            ODP_SCAN,
                            ODP_SCREENSHOT,
                            VISUAL_AUTHENTICITY_OTHER,
                            VISUAL_AUTHENTICITY_PICTURE_FACE_INTEGRITY,
                            VISUAL_AUTHENTICITY_SECURITY_FEATURES,
                            VISUAL_AUTHENTICITY_TEMPLATE,
                            POST_PROCESSING_COMMENT,
                            JSON_BODY_INDEX);


SHOW TASKS;

