select m.signup_date,
       ekyc.merchant_id,
       case
           when m.is_company is true then 'Company'
           else 'Sole Trader'
           end                           as legal_type,
       m.legal_type                      as long_legal_type,
       m.mcc_level                       as mcc,
       m.merchant_country,
       m.merchant_global_region,
       m.regulatory_environment          as license,

       ekyc.check_status                  as external_id_check,
       platform_check                    as platform_ekyc_check,
       ekyc.external_id_check_time,
       ekyb.kyc_action_status            as company_identity_check,
       onfido.status                     as onfido_check,
       onfido.created_at                 as onfido_check_time,
       aml.aml_risk_level,
       case
           when bank.merchant_code is null then false
           else true
           end                           as sumup_bank,
       case when c.source = 'BANK_FIRST' then true
           else false
               end as bank_first,
       coalesce(tpv.nb_successful_tx, 0) as tx_count,
       coalesce(tpv.tpv_total_eur, 0)    as tpv_eur,
       case
           when external_id_check_time <= onfido.created_at then true
           when onfido.created_at is null then null
           else false
           end                           as onfido_check_after,
       mas.account_status,
       mas.account_substatus
from (select distinct on (kyc.merchant_id) kyc.merchant_id,
                                           ka.name        as check_type,
                                           kas.name       as check_status,
                                           kyc.created_at as external_id_check_time,
                                           case
                                               when kyc_action_id = 1249 then true
                                               else false
                                               end        as platform_check
      from kyc_logs kyc
               left join kyc_actions ka on kyc.kyc_action_id = ka.id
               left join kyc_action_statuses kas on kyc.kyc_action_status_id = kas.id
      where kyc.kyc_action_id in (82, 1249)
        and kas.name = 'EXTERNAL_ID_CHECK_PASS'
      order by kyc.merchant_id, kyc.created_at desc) ekyc
         left join olap.v_m_dim_merchant m on ekyc.merchant_id = m.merchant_id
         left join (select distinct on (merchant_id) merchant_id, status, created_at
                    from public.merchant_id_verifications
                    order by merchant_id, created_at desc) onfido
                   on ekyc.merchant_id = onfido.merchant_id and
                      onfido.created_at >= ekyc.external_id_check_time
         left join (select distinct on (merchant_id) merchant_id,
                                                     created_at,
                                                     ka.name  as kyc_action,
                                                     kas.name as kyc_action_status
                    from kyc_logs kyc
                             left join kyc_actions ka on kyc.kyc_action_id = ka.id
                             left join kyc_action_statuses kas on kyc.kyc_action_status_id = kas.id
                    where kyc.kyc_action_id = 1245
                    order by merchant_id, created_at desc) ekyb on ekyc.merchant_id = ekyb.merchant_id
         left join antifraud.merchant_aml_profile aml on m.merchant_code = aml.merchant_code
         left join (select company_code as merchant_code
                    from core_banking.accounts a
                             left join core_banking.users u on u.id = a.owner_id) bank
                   on m.merchant_code = bank.merchant_code
         left join card.clients c on c.code = m.merchant_code
         left join olap.v_m_facts_transaction tpv on m.dim_merchant_id = tpv.dim_merchant_id
         left join olap.v_m_dim_account_status mas on m.dim_merchant_id = mas.dim_merchant_id
         left join users u on m.primary_user_id = u.id
where m.is_test is false
  and mas.account_status = 'ACTIVE'
  and u.email not ilike '%@sumup.com'
  and m.signup_date >= '2019-04-01';
--  and merchant_country != 'BR';

