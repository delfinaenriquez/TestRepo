SELECT *
  FROM (select h.po_header_id,
                h.revision_num,
                h.segment1 PO_NUM,
                H.INTERFACE_SOURCE_CODE,
                h.comments,
                h.DOCUMENT_STATUS,
                h.APPROVED_FLAG,
                h.ENABLED_FLAG,
                h.last_update_date,
                h.CLOSED_DATE,
                h.CANCEL_FLAG,
                pah.action_date cancel_date,
                h.REQUEST_ID,
                h.FUNDS_STATUS,
                (h.creation_date) creation_date,
                h.created_by,
                h.vendor_id,
                h.vendor_site_id,
                s.vendor_site_code,
                hp.party_name,
                
                h.TYPE_LOOKUP_CODE,
                
                (SELECT T.DESCRIPTION
                   FROM PO_LINE_TYPES_TL T
                  WHERE T.LINE_TYPE_ID = pl.LINE_TYPE_ID
                    AND T.LANGUAGE = 'E') LINE_TYPE,
                
                pl.ITEM_ID,
                
                esib.ITEM_NUMBER,
                
                D.DESTINATION_TYPE_CODE,
                
                D.ACCRUE_ON_RECEIPT_FLAG,
                
                d.DELIVER_TO_PERSON_ID,
                (SELECT hr.full_name
                   FROM PER_PERSON_NAMES_F hr
                  WHERE d.DELIVER_TO_PERSON_ID = hr.PERSON_ID
                    and hr.NAME_TYPE = 'GLOBAL'
                    AND ROWNUM = 1) solicitante,
                pll.INPUT_TAX_CLASSIFICATION_CODE tax_clasif_code,
                
                sum(d.QUANTITY_ORDERED) QUANTITY_ORDERED,
                sum(d.QUANTITY_DELIVERED) QUANTITY_DELIVERED,
                sum(d.QUANTITY_BILLED) QUANTITY_BILLED,
                sum(d.QUANTITY_CANCELLED) QUANTITY_CANCELLED
         
           from po_headers_all           h,
                POZ_SUPPLIERS            ps,
                poz_supplier_sites_all_m s,
                hz_parties               hp,
                
                po_lines_all pl,
                
                po_distributions_all d,
                
                EGP_SYSTEM_ITEMS_B esib,
                
                (SELECT pah1.object_type_code,
                        pah1.object_id,
                        pah1.ACTION_CODE,
                        PAH1.ACTION_DATE,
                        pah1.ROLE_CODE
                   FROM PO_ACTION_HISTORY PAH1
                  WHERE pah1.object_type_code = 'PO'
                       --AND pah1.ACTION_CODE = 'CLOSE'
                       --AND pah1.ROLE_CODE = 'BUYER'--'SYSTEM'   
                    AND PAH1.sequence_num =
                        (select max(pah2.sequence_num)
                           from PO_ACTION_HISTORY PAH2
                          where pah2.OBJECT_ID = pah1.OBJECT_ID)) pah,
                
                PO_LINE_LOCATIONS_ALL pll,
                INV_ORG_PARAMETERS IOP
         
          where
         
          h.vendor_id = ps.vendor_id
       and h.vendor_id = s.vendor_id
       and h.vendor_site_id = s.vendor_site_id
       and ps.party_id = hp.party_id
         
       and h.po_header_id = pl.po_header_id
         
       and h.po_header_id = d.po_header_id
         
       and d.po_line_id = pl.po_line_id
         
         --h.COMMENTS like 'Carga Inicial%' AND
         --NVL(h.APPROVED_FLAG, 'N') = 'N' AND
         
         --AND h.segment1 = nvl(:p_num_oc,h.segment1)
         
      --and h.segment1 in ('12')
         
         --and substr(h.segment1, 3, length(h.segment1))='635871'
         --and h.DOCUMENT_STATUS not in ('INCOMPLETE')
         /*and not exists (select 'yes'
          from po_headers_all h1
         where substr(h1.segment1, 3, length(h1.segment1)) =
               substr(h.segment1, 3, length(h.segment1))
          and document_status = 'OPEN')*/
         --and trunc(h.creation_date)= to_Date('21/05/2021','dd/mm/yyyy')
         /*and t.TRANSACTION_TYPE = 'RECEIVE'
         and h.po_header_id = t.po_header_id
         and t.SHIPMENT_HEADER_ID = sh.SHIPMENT_HEADER_ID
         and not exists (select 'yes'
            from rcv_transactions t2, RCV_SHIPMENT_HEADERS sh2
           where t2.SHIPMENT_HEADER_ID = sh2.SHIPMENT_HEADER_ID
             and sh2.RECEIPT_NUM = sh.RECEIPT_NUM
             and t2.TRANSACTION_TYPE = 'RETURN TO VENDOR')*/
         
       and pl.ITEM_ID = esib.inventory_item_id
       and esib.organization_id = d.DESTINATION_ORGANIZATION_ID
       and d.destination_organization_id = IOP.ORGANIZATION_ID
       AND IOP.ORGANIZATION_CODE = 'CHO'
         
       and pah.object_id = h.po_header_id
       --and h.DOCUMENT_STATUS = 'FINALLY CLOSED'
         
       and esib.ITEM_NUMBER like '01.038.00005'
         
       and h.po_header_id = pll.po_header_id
       and pl.po_line_id = pl.po_line_id
         
         --and pll.INPUT_TAX_CLASSIFICATION_CODE <> 'PE_RATE_IGV_REACTIVA'
         --and h.DOCUMENT_STATUS  in ('CLOSED FOR RECEIVING') -- CLOSED FOR RECEIVING,OPEN,CLOSED,CANCELED
         
       --AND D.DESTINATION_TYPE_CODE = 'EXPENSE'
         
         --AND NVL(h.CLOSED_DATE, SYSDATE) < TO_DATE('24/07/23', 'DD/MM/YY')
         --AND H.CURRENCY_CODE = 'PEN'
          group by h.po_header_id,
                   h.revision_num,
                   h.segment1,
                   H.INTERFACE_SOURCE_CODE,
                   h.comments,
                   h.DOCUMENT_STATUS,
                   h.APPROVED_FLAG,
                   h.ENABLED_FLAG,
                   h.CLOSED_DATE,
                   h.CANCEL_FLAG,
                   pah.action_date,
                   h.REQUEST_ID,
                   h.FUNDS_STATUS,
                   h.creation_date,
                   h.created_by,
                   h.vendor_id,
                   h.vendor_site_id,
                   s.vendor_site_code,
                   hp.party_name,
                   
                   h.TYPE_LOOKUP_CODE,
                   pl.LINE_TYPE_ID,
                   D.DESTINATION_TYPE_CODE,
                   D.ACCRUE_ON_RECEIPT_FLAG,
                   h.LAST_UPDATE_DATE,
                   --hr.full_name,
                   d.DELIVER_TO_PERSON_ID,
                   pl.ITEM_ID,
                   esib.ITEM_NUMBER,
                   pll.INPUT_TAX_CLASSIFICATION_CODE) T
 WHERE /*T.QUANTITY_DELIVERED = T.QUANTITY_BILLED
   AND*/ T.PO_NUM = nvl(:p_num_oc, T.PO_NUM)
