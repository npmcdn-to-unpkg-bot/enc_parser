open Data
open DataLib

exception ENCLibParseError of string*string


let msg (str:string) = 
                print_string (str^"\n")
        
let error k msg =  raise (ENCLibParseError(k,msg))

module ENCParseLib = 
struct
       let init_state () : parse_state = 
                {
                        record_id = None;
                        dataset_info = DataLib.make_dataset_info ();
                }
        
        let upd_dataset (s:parse_state) (f:dataset_info->dataset_info) =
               s.dataset_info <- (f s.dataset_info)
 
        let upd_dataset_stats (s:parse_state) (f:dataset_stats->dataset_stats) =
               s.dataset_info.stats <- (f s.dataset_info.stats)
        
        let upd_dataset_coord_info (s:parse_state) (f:dataset_coord_info ->
                dataset_coord_info) = 
                s.dataset_info.coord_info <- (f s.dataset_info.coord_info)
        
        let upd_lexical_levels (s:parse_state) (f:lexical_levels->lexical_levels) =
               s.dataset_info.lex <- (f s.dataset_info.lex)
        
        let make_dataset (s:parse_state) = 
                {info = s.dataset_info} 
        
        let set_record (s:parse_state) (i:int) = 
                let _ = s.record_id <- Some i in
                ()
        
        let to_hex x = 
                "0x"^x 

        let name_to_foreign_ptr (x:string) : foreign_ptr = 
                let rcname = DataLib.int_to_record_type (int_of_string
                (to_hex (String.sub x 0 2)) ) in  
                let rcid = int_of_string (to_hex (String.sub x 2 ((String.length x)
                -2))) in 
               (rcname,rcid)
        
        let long_name_to_feature_obj_id (x:string) =
                (*AGEN=3 hex, FIDN=4 bytes (hex 8), FIDS=2 bytes (hex 4)*)
                (*let _ = msg x in*)
                let agen = int_of_string(to_hex (String.sub x 0 3)) in 
                let fidn = int_of_string (to_hex (String.sub x 3 8)) in 
                let fids = int_of_string (to_hex (String.sub x 11 4)) in 
                (agen,fidn,fids)
 
end
