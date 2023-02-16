with ekyc_checks as (select ar.id           as processing_id,
                            ar.created_at   as processing_date,
                            ar.request_status,
                            ar.ref,
                            ar.country_code as merchant_country,
                            ar.verification_status,
                            arps.provider
                     from kyc.app_requests ar
                              join kyc.app_request_provider_statuses arps
                                   on arps.app_request_id = ar.id and ar.ref::text = arps.ref::text
                     where ar.app_id = 1
                       and ar.request_type::text = any (array ['PERSON/IDENTITY'::text, 'IDENTITY'::text])
                     UNION
                     select ar.id           as processing_id,
                            ar.created_at   as processing_date,
                            ar.request_status,
                            ar.ref,
                            ar.country_code as merchant_country,
                            ar.verification_status,
                            arps.provider
                     from kyc.archived_app_requests ar
                              join kyc.archived_app_request_provider_statuses arps
                                   on arps.app_request_id = ar.id and ar.ref::text = arps.ref::text
                     where ar.app_id = 1
                       and ar.request_type::text = any (array ['PERSON/IDENTITY'::text, 'IDENTITY'::text])
                       and ar.created_at >= '2020-01-01')
select row_number() over (partition by ref order by processing_date desc ) as check_no,
       processing_id,
       processing_date,
       request_status,
       ref,
       ekyc.merchant_country,
       verification_status,
       count(distinct (provider))                                          as count_providers,
       string_agg(provider, ' + ' order by provider)                       as providers_list,
       m.merchant_id                                                       as merchant_id,
       m.primary_user_id,
       m.mcc_level                                                         as mcc,
       case
           when m.is_company is true then 'Comapny'
           else 'Sole Trader'
           end                                                             as legal_type,
       m.legal_type                                                        as long_legal_type,
       m.regulatory_environment                                            as license,
       masd.photo_id_config,
       aml.aml_risk_level,
       vpftaf.tpv_total_eur,
       tpv_365_days_eur,
       tpv_60_days_eur,
       tpv_30_days_eur,
       tpv_7_days_eur
from ekyc_checks ekyc
         join olap.v_m_dim_merchant m on ekyc.ref = m.merchant_code
         left join public.merchant_account_statuses mas on m.merchant_id = mas.merchant_id
         left join public.merchant_account_status_details masd on mas.id = masd.merchant_account_status_id
         left join public.users u on m.primary_user_id = u.id
         left join antifraud.merchant_aml_profile aml on m.merchant_code = aml.merchant_code
         left join olap.v_m_facts_transaction vpftaf on vpftaf.dim_merchant_id = m.dim_merchant_id
where is_test is false
  and u.email not ilike '%@sumup.com'
group by 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22