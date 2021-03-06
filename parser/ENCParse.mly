
%token <int> Int
%token <string> String
%token <string> Hex
%token <float> Decimal
%token <string> Token 
%token <char>  Byte 

%token EOF
%token EOL
%token FIELD, RECORD, BYTES 
%token OPARAN, CPARAN, FSLASH, COLON, EQ 

%token DSID,DSDATASET
%token RCNM, RCID, EXPP, INTU, DSNM, EDTN UPDN, UADT,
ISDT,STED,PRSP,PSDN,PRED,PROF,AGEN,COMT

%token DSSI,DSDATASTRUCT
%{
        open Common
        
        open Data
        open DataLib
        open DataStructure 
        
        open FeatureParseLib
        open ENCParseLib

        exception ENCParseError of string*string
        
        let _state = ENCParseLib.init_state();;
        
        let msg (str:string) = 
                print_string (str^"\n")
        
        let error k msg = 
                raise (ENCParseError(k,msg))
%}
%token DSTR, AALL, NALL, NOMR, NOCR, NOGR, NOLR, NOIN, 
NOCN, NOED, NOFA

%token DSPM,DSPARAM
%token HDAT, VDAT, SDAT, CSCL, DUNI, HUNI, PUNI, COUN, COMF, SOMF

%token VRID, DSVECTID
%token RVER,RUIN

%token SG3D,DS3DCOORDS
%token YC00,XC00,VE3D

%token SG2D, DS2DCOORD

%token DSVECTATTR, ATTV
%token ATTL, ATVL

%token DSVECTPTR, VRPT
%token NAME, ORNT, USAG, TOPI, MASK

%token DSFEATID, FRID
%token OBJL, GRUP, PRIM

%token DSFEATOBJID, FOID
%token FIDN, FIDS

%token DSFEATATTR, ATTF 

%token DSFEATSPAT, FSPT

%token DSFEATOBJPTR, FFPT
%token LNAM, RIND

%token DSFEATSPATCTRL, FSPC
%token FSUI FSIX NSPT 

%token DSFEATOBJPTRCTRL, FFPC
%token FFUI FFIX NFPT

%token RECORDID

%start toplevel

%type <Data.dataset option> toplevel
%%

eol:
| EOL                                           {()}
| EOF                                           {()}
(* dataset identification field structure*)
dsi_stmt:
(*record name*)
|  RCNM EQ Int eol {                                
        let _ = assert($3=10) in ()
}
(*record identificatio number*)
|  RCID EQ Int eol {
        let id = $3 in
        let _ = ENCParseLib.upd_dataset _state 
                (fun ds -> stmt (ds.id <- id) ds) in  
        ()
}
(*exchange purpose*)
|  EXPP EQ Int eol  {
        let expp = DataLib.int_to_exchange_purpose $3 in
        let _ = ENCParseLib.upd_dataset _state 
                (fun ds -> stmt (ds.exchange <- expp) ds)
        in
        ()        
}
(*intended usage*)
|  INTU EQ Int eol {
        let intu = DataLib.int_to_intended_usage $3 in
        let _ = ENCParseLib.upd_dataset _state 
                (fun ds -> stmt (ds.usage <- intu) ds)
        in
        ()
}
(*data set name*)
|  DSNM EQ String eol { 
         let name = $3 in 
         let _ = ENCParseLib.upd_dataset _state
                (fun ds -> stmt (ds.name <- name) ds) 
         in 
         ()
}
(*edition number*)
|  EDTN EQ String eol  {
         let edition_no = int_of_string $3 in  
         let _ = ENCParseLib.upd_dataset _state
                (fun ds -> stmt (ds.edition <- edition_no) ds) 
         in 
         ()
}
(*update number, the index of the update*)
|  UPDN EQ String eol  {
        let update_no = int_of_string $3 in  
        let _ = ENCParseLib.upd_dataset _state
                (fun ds -> stmt (ds.update <- update_no) ds) 
        in 
        ()
}
(*update application date, the application date*)
|  UADT EQ String eol  {
        let upd_app_date = 
                if $3 = "        " then
                        None
                else
                        let uadt = int_of_string $3 in 
                        Some (DataLib.int_to_date uadt) 
        in
        let _ = ENCParseLib.upd_dataset _state 
                (fun ds -> stmt (ds.update_app_date <- upd_app_date) ds )
        in
        ()
}
(*issue date*)
|  ISDT EQ String eol {
        let upd_issue_date = 
                if $3 = "        " then
                        None
                else
                        let uadt = int_of_string $3 in 
                        Some (DataLib.int_to_date uadt) 
        in
        let _ = ENCParseLib.upd_dataset _state 
                (fun ds -> stmt (ds.issue_date <- upd_issue_date) ds )
        in
        ()
}
(*edition number of the S-57 spec*)
|  STED EQ Decimal eol {
        let _ = assert($3 = 3.1) in 
        ()
}
(*produce specification*)
|  PRSP EQ Int eol {
        let _ = assert($3 = 1) in 
        ()
}
(*a string identifying a non-standad product specification*)
|  PSDN EQ String eol  {
        let _ = assert ($3 = "") in 
        ()
}
(*a string identifying the dition number of th eproduct specifciation*)
|  PRED EQ String eol   {
        let _ = assert ($3 = "2.0") in 
        ()
}
(*application profile information.*)
|  PROF EQ Int eol   {
        let code = DataLib.int_to_application_profile $3 in
        let _ = ENCParseLib.upd_dataset _state
                (fun ds -> stmt (ds.app_profile <- code) ds)
        in 
        ()
}
(*agency code*)
|  AGEN EQ Int eol    {
        let code = $3 in
        let _ = ENCParseLib.upd_dataset _state
                (fun ds -> stmt (ds.agency_id <- (code,None)) ds)
        in 
        ()
}
(*a comment*)
|  COMT EQ String eol {
        let comment = $3 in 
        let _ = ENCParseLib.upd_dataset _state
                (fun ds -> stmt (ds.comment <- comment ) ds)
        in 
        ()
}

dsi_stmts:
| dsi_stmt {()}
| dsi_stmts dsi_stmt {()}

dsst_stmt:
| DSTR EQ Int eol  {
        let data_structure = DataLib.int_to_data_struct_type $3 in 
        let _ = ENCParseLib.upd_dataset _state
                (fun st -> stmt (st.structure <- data_structure) st)
        in
        ()
}        

(*lexical level used for AATF fields*)
| AALL EQ Int eol {
        let lexical_level = DataLib.int_to_lexical_level $3 in 
        let _ = assert (lexical_level != LLUnicode) in 
        let _ = ENCParseLib.upd_lexical_levels _state
                (fun st -> stmt (st.attf_lex <- lexical_level) st)
        in
        ()
}
(*lexical level used for NATF fields*)
| NALL EQ Int eol {
        let lexical_level = DataLib.int_to_lexical_level $3 in 
        let _ = ENCParseLib.upd_lexical_levels _state
                (fun st -> stmt (st.natf_lex <- lexical_level) st)
        in
        ()
}
(*number of meta records in dataset*)
| NOMR EQ Int eol {
        let n_meta = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_meta <- n_meta) st)
        in
        ()
}
(*number of cartographic records in dataset*)
| NOCR EQ Int eol  {
        let n_cart = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_cartographic <- n_cart) st)
        in
        ()
}

(*number of geo records in dataset*)
| NOGR EQ Int eol  {
        let n_geo = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_geo <- n_geo) st)
        in
        ()
}
(*number of collection records in dataset*)
| NOLR EQ Int eol  {
        let n_coll = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_collection <- n_coll) st)
        in
        ()
}

(*number of isolated node records in dataset*)
| NOIN EQ Int eol {
        let n_isol = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_isolated_node <- n_isol) st)
        in
        ()
}

(*number of connected node records in dataset*)
| NOCN EQ Int eol {
        let n_conn = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_connected_node <- n_conn) st)
        in
        ()
}

(*number of edge records in dataset*)
| NOED EQ Int eol {
        let n_edge = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_edge <- n_edge) st)
        in
        ()
} 
(*number of face records in dataset*)
| NOFA EQ Int eol {
        let n_face = $3 in 
        let _ = ENCParseLib.upd_dataset_stats _state
                (fun st -> stmt (st.n_face <- n_face) st)
        in
        ()
}

dsst_stmts:
| dsst_stmts dsst_stmt {()}
| dsst_stmt  {()}

(*Data set parameter field structure. 7.3.2.1*)
dspar_stmt:
|  RCNM EQ Int eol                                
        {let _ = assert($3 == 20) in ()}

|  RCID EQ Int eol {
        let id = $3 in 
        ()
}
(*horizontal geodetic datum*)
|  HDAT EQ Int eol {
        let horiz_val = DataLib.int_to_horiz_ref $3 in
        assert (horiz_val = HRWGS84);
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.horiz <- horiz_val) met)
        in
        () 
}
(*vertical geodetic datum*)
|  VDAT EQ Int eol { 
        let vert_val = DataLib.int_to_vert_ref $3 in
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.vert <- vert_val) met)
        in
        () 
}

(*sounding datum*)
|  SDAT EQ Int eol  { 
        let snd_val = DataLib.int_to_vert_ref $3 in
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.sounding <- snd_val) met)
        in
        () 
}

(*compilation scale of the data. for example 1:x is encoded as x.*)
|  CSCL EQ Int eol   { 
        let comp_scale = $3 in
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.compilation_scale <- comp_scale) met)
        in
        () 
}

(*units of depth measurement*)
|  DUNI EQ Int eol {
        let depth_units = DataLib.int_to_depth_units $3 in
        assert (depth_units = DUMeters);
        let _ = ENCParseLib.upd_dataset_coord_info _state 
                (fun met -> stmt (met.depth_units <- depth_units) met)
        in 
        ()
}
(*units of height measurement*)
|  HUNI EQ Int eol {
        let height_unit = DataLib.int_to_height_units $3 in 
        assert (height_unit = HUMeters);
        let _ = ENCParseLib.upd_dataset_coord_info _state 
                (fun met -> stmt (met.height_units <- height_unit) met)
        in 
        ()
}
(*units of positional accuracy *)
|  PUNI EQ Int eol {
        let pos = DataLib.int_to_pos_accuracy_units $3 in 
        assert (pos = PUMeters);
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.positional_accuracy <- pos) met)
        in
        ()
}      
(*coordinate units *)
|  COUN EQ Int eol {
        let coord_units = DataLib.int_to_coordinate_unit $3 in 
        assert (coord_units = CULatLong); 
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.coord_units <- coord_units) met)
        in
        ()
}
(*floating point to integer multiplication factor for coordinate*)
|  COMF EQ Int eol {
        let coordinate_mult_factor = $3 in 
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.coord_mult_factor <-
                        coordinate_mult_factor) met)
        in
        ()
}
(*floating point to integer multiplication factor for sounding values*)
|  SOMF EQ Int eol {
        let sounding_mult_factor = $3 in 
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.sound_mult_factor <-
                        sounding_mult_factor) met)
        in
        ()
}
(*comment*)
|   COMT EQ String eol  {
        let comment = $3 in 
        let _ = ENCParseLib.upd_dataset_coord_info _state
                (fun met -> stmt (met.comment <- comment) met)
        in
        ()
}

dspar_stmts:
| dspar_stmt {()}
| dspar_stmts dspar_stmt {()}

vcid_stmt:
| RCNM EQ Int eol  {
        let vtyp : vector_type = DataLib.int_to_vect_type $3 in 
        let _ = ENCParseLib.upd_vector_record_info _state 
                (fun q -> stmt (q.typ <- vtyp) q)
        in
           ()
}
| RCID EQ Int eol  {
        let vid = $3 in 
        let _ = ENCParseLib.upd_vector_record_info _state
                (fun q -> stmt (q.id <- vid) q)
        in
        ()
}
| RVER EQ Int eol  {
        let _ = $3 in 
        ()
} 
| RUIN EQ Int eol  {
        let vupdinst : update_instruction = DataLib.int_to_update_inst $3 in 
        let _ = ENCParseLib.upd_vector_record_info _state
                (fun q -> stmt (q.op <- vupdinst) q)
        in
        ()
}

vcid_stmts:
| vcid_stmt {()}
| vcid_stmts vcid_stmt {()}

(*y coordinate, x coordinate and sounding value*)
coord3d_stmt:
| YC00 EQ Int eol 
  XC00 EQ Int eol                                       
  VE3D EQ Int eol  {
        let y:int = $3 in 
        let x:int = $7 in 
        let z:int = $11 in
        (*compute coordinate*) 
        let x,y,z = ENCParseLib.proc_coords _state x y z in
        (x,y,z)
}

coord3d_stmts:
| coord3d_stmt {let coord = $1 in [coord]}
| coord3d_stmt coord3d_stmts  
{
        let coord = $1 in
        let coords = $2 in 
        coord::coords
}

coord2d_stmt:
| YC00 EQ Int eol 
  XC00 EQ Int eol  {
        let y:int = $3 in 
        let x:int = $7 in 
        let x,y,_ = ENCParseLib.proc_coords _state x y 0 in 
        (x,y)
}


coord2d_stmts:
| coord2d_stmt {let coord = $1 in [coord]}
| coord2d_stmt coord2d_stmts {
        let coord = $1 in 
        let coords = $2 in 
        coord::coords
}

attr_stmt:
| ATTL EQ Int eol 
  ATVL EQ String eol {
        let code = $3 in
        let value = $7 in  
        (code,value)
}

attr_stmts:
| attr_stmt {
        let m : (int,string) map= MAP.make () in 
        let k,v = $1 in 
        MAP.put m k v  
}
| attr_stmts attr_stmt {
        let m = $1 in 
        let k,v = $2 in 
        MAP.put m k v
}

vectptr_stmt:
| NAME EQ Hex eol
  ORNT EQ Int eol 
  USAG EQ Int eol
  TOPI EQ Int eol
  MASK EQ Int eol {
        let foreign_ptr = ENCParseLib.name_to_foreign_ptr $3 in 
        let orientation  = DataLib.int_to_orientation $7 in
        let usage_indicator  = DataLib.int_to_usage_indicator $11 in  
        let topology_indicator  = DataLib.int_to_topology_indicator $15 in
        let mask = DataLib.int_to_mask $19 in 
        {       
                ptr=foreign_ptr;
                orientation=orientation;
                usage=usage_indicator;
                topology=topology_indicator;
                mask=mask;        
        } 
}

vectptr_stmts:
| vectptr_stmt {[$1]}
| vectptr_stmt vectptr_stmts {$1::$2}

featid_stmt:
|        RCNM EQ Int eol                                {()}
|        RCID EQ Int eol                                {()}
|        PRIM EQ Int eol                                {()}
|        GRUP EQ Int eol                                {()}
|        OBJL EQ Int eol                                {()}
|        RVER EQ Int eol                                {()}
|        RUIN EQ Int eol                                {()}

featid_stmts:
| featid_stmt                   {()}
| featid_stmts featid_stmt      {()}

featobjid_stmt:
| AGEN EQ Int eol {()}
| FIDN EQ Int eol {()}
| FIDS EQ Int eol {()}

featobjid_stmts:
| featobjid_stmt                {()}
| featobjid_stmts featobjid_stmt {()}

featspat_stmt:
| NAME EQ Hex eol  {
        let foreign_ptr = ENCParseLib.name_to_foreign_ptr $3 in 
        ()
}
| ORNT EQ Int  eol {
        let orientation = DataLib.int_to_orientation $3 in
        () 
}
| USAG EQ Int  eol  {
        let usage = DataLib.int_to_usage_indicator $3 in 
        ()
}
| MASK EQ Int  eol  {
        let mask = DataLib.int_to_mask_type $3 in 
        ()
}       

featspat_stmts:
| featspat_stmt                               {()}
| featspat_stmts featspat_stmt                {()}

featspat_ctrl_stmt:
| FSUI EQ Int eol {
        ()
}
| FSIX EQ Int eol {
        ()
}
| NSPT EQ Int eol {
        ()
}

featspat_ctrl_stmts:
| featspat_ctrl_stmt                            {()}
| featspat_ctrl_stmts featspat_ctrl_stmt        {()}

featobjptr_stmt:
| LNAM EQ Hex eol  {
        let _ = ENCParseLib.long_name_to_feature_obj_id $3 in 
        ()
} 
| RIND EQ Int eol                                    {()}
| COMT EQ String eol                                 {()}

featobjptr_stmts:
| featobjptr_stmt                              {()}
| featobjptr_stmts featobjptr_stmt             {()}

featobjptr_ctrl_stmt:
| FFUI EQ Int eol {
        ()
}
| FFIX EQ Int eol {
        ()
}
| NFPT EQ Int eol {
        ()
}

featobjptr_ctrl_stmts:
| featobjptr_ctrl_stmt                            {()}
| featobjptr_ctrl_stmts featobjptr_ctrl_stmt        {()}


stmt:
|        RECORD Int OPARAN Int BYTES CPARAN eol              {
                let index : string  =string_of_int $2 in 
                let nbytes : string = string_of_int $4 in 
                ()
        }
|        FIELD Int COLON RECORDID eol                        {
                let record_id = $2 in 
                let _ = ENCParseLib.set_record _state record_id in 
                ()
        }
|        FIELD DSID COLON DSDATASET eol dsi_stmts            {
                let elem = $6 in 
                ()
        }
|        FIELD DSSI COLON DSDATASTRUCT eol dsst_stmts        {
                let elem = $6 in 
                ()
        }
|        FIELD DSPM COLON DSPARAM eol dspar_stmts            {
                let elem = $6 in 
                ()
        }
|        FIELD VRID COLON DSVECTID eol vcid_stmts  {

}
|        FIELD SG3D COLON DS3DCOORDS eol coord3d_stmts {
                let coords : (float*float*float) list = $6 in 
                let _ = ENCParseLib.commit_coords _state (Vect3D coords) in 
                ()
}
|        FIELD SG2D COLON DS2DCOORD eol coord2d_stmts   {
                let coords : (float*float) list = $6 in 
                let _ = ENCParseLib.commit_coords _state (Vect2D coords) in 
                ()

} 
|        FIELD ATTV COLON DSVECTATTR eol attr_stmts  {
                let attrs : (int,string) map = $6 in 
                let _ = FeatureParseLib.to_entity_type 
                        (int_of_string (MAP.get attrs 402)) in
                () 
}
|        FIELD VRPT COLON DSVECTPTR eol vectptr_stmts  {
                let ptrs : geom_ptr list= $6 in 
                let _ = ENCParseLib.commit_geom_rels _state ptrs in 
                ()
}   
|        FIELD FRID COLON DSFEATID eol featid_stmts   {
                () 
}
|        FIELD FOID COLON DSFEATOBJID eol featobjid_stmts  {
                ()
} 
|        FIELD ATTF COLON DSFEATATTR eol attr_stmts   { 
                let attrs : (int,string) map = $6 in 
                ()
} 
|        FIELD FSPT COLON DSFEATSPAT eol featspat_stmts  {
  
}
|        FIELD FFPT COLON DSFEATOBJPTR eol featobjptr_stmts  {
  
}
|        FIELD FSPC COLON DSFEATSPATCTRL eol featspat_ctrl_stmts {
        
};
|        FIELD FFPC COLON DSFEATOBJPTRCTRL eol featobjptr_ctrl_stmts {

};
stmts:
|        stmts stmt {()}
|        stmt {()}
;

toplevel:
|        stmts EOF {Some (ENCParseLib.make_dataset _state)}

|        EOF {None}
;
