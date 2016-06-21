
open Data

exception DataLibParseError of string*string


let msg (str:string) = 
                print_string (str^"\n")
        
let error k msg =  raise (DataLibParseError(k,msg))


module DataLib =
struct
        let make_lexical_levels () = {
                        attf_lex = LLASCII;
                        natf_lex = LLASCII;
                }

        let make_dataset_stats () =
        {
                n_meta = 0;
                n_cartographic=0;
                n_geo=0;
                n_collection=0;
                n_isolated_node=0;
                n_connected_node=0;
                n_edge=0;
                n_face=0;
        }
        let make_dataset_coord_info () =
        {
        horiz = 0;
        vert = 0;
        sounding = 0;
        compilation_scale= 0;
        depth_units = 0;
        height_units = 0;
        positional_accuracy = 0;
        coord_units = CULatLong;
        coord_mult_factor = 0;
        sound_mult_factor = 0;
        comment= "";
        }


        let make_dataset_info () = 
                {
                        id=0;
                        (*wheter it is new or updated*)
                        exchange=EXNew;
                        edition=1;
                        update=0;
                        (*all changes before this one have been applied*)
                        update_app_date=None;
                        (*date on which this was made available*)
                        issue_date=None;
                        name="(no name)";
                        (*the intended usage*)
                        usage=IUUnknown;
                        agency_id=(0,None);
                        comment="";
                        app_profile=APElecNavChart;
                        stats=make_dataset_stats ();
                        lex=make_lexical_levels ();
                        coord_info=make_dataset_coord_info ();
                }
 
        let int_to_exchange_purpose (i:int) = match i with
                |1 -> EXNew 
                |2 -> EXUpdate 
                |_ -> error "int_to_dataset_kind" "no dataset kind of that number"
        
        let exchange_purpose_to_string (e:exchange_purpose) = match e with 
                | EXNew -> "dataset_new"
                | EXUpdate -> "dataset_update"

        let int_to_intended_usage (i:int) = match i with
                | 1 -> IUOverview
                | 2 -> IUGeneral
                | 3 -> IUCoastal
                | 4 -> IUApproach
                | 5 -> IUHarbor
                | 6 -> IUBerthing
                | _ -> error "int_to_intended_usage" "no intended usage" 
       
        let intended_usage_to_string (e:intended_usage) : string = match e with 
                | IUOverview -> "overview"
                | IUGeneral -> "general"
                | IUCoastal -> "coastal"
                | IUApproach -> "approach"
                | IUHarbor -> "harbor"
                | IUBerthing -> "berthing"
        (*

type application_profile = APElecNavCharts | APElecNavRevision | APIHOObjectCat
         *)
        let int_to_application_profile (i:int) = match i with
        | 1 -> APElecNavChart
        | 2 -> APElecNavRevision 
        | 3 -> APIhoObjCatalog
        | _ -> error "int_to_application_profile" "unknown id"
        
        let int_to_data_struct_type (i:int) = match i with 
        | 1 -> DSCartographicSpaghetti (*cartographic spaghetti*)
        | 2 -> DSChainNode (*chain node*)
        | 3 -> DSPlanarGraph (*planar graph*)
        | 4 -> DSFullTopology (*full topologu*)
        | 255 -> DSNotRelevent (*topology not relevent*)
        
        let int_to_update_inst (i:int) = match i with 
        | 1 -> USInsert
        | 2 -> USDelete
        | 3 -> USModify          
        
        let int_to_lexical_level (i:int) = match i  with 
        | 0 -> LLASCII 
        | 1 -> LLLatin
        | 2 -> LLUnicode
        | _ -> error "int_to_lexical_level" "unknown lexical level"
        
        let int_to_coordinate_unit (i:int) = match i with 
        | 1 -> CULatLong
        | 2 -> CUEastNorth 
        | 3 -> CUUnitsOnChartMap
        | _ -> error "int_to_coordinate_unit" "unkonwn coordinate unit"
        
        let int_to_vect_type (i:int) = match i with 
        | 110 -> VIsolatedNode 
        | 120 -> VConnectedNode 
        | 130 -> VEdge 
        | 140 -> VFace
       
        let int_to_mask_type (i:int) = match i with 
        | 1 -> MKMask
        | 2 -> MKShow
        | 255 -> MKIrrelevent
        | _ -> error "int_to_mask_type" "unknown value"
        
        let int_to_usage_indicator (i:int) = match i with 
        | 1 -> UIExterior
        | 2 -> UIInterior
        | 3 -> UIExteriorTrunc 
        | 255 -> UIIrrelevent
        | _ -> error "int_to_usage_indicator" ("unknown value: "^(string_of_int
        i))

        let int_to_orientation (i:int) = match i with
        | 1 -> ORForward
        | 2 -> ORReverse
        | 255 -> ORIrrelevent
        | _ -> error "int_to_orientation" "unknown value"
        
        let int_to_topology_indicator (i:int) = match i with 
        | 1 -> TIBeginNode 
        | 2 -> TIEndNode
        | 3 -> TILeftFace
        | 4 -> TIRightFace
        | 5 -> TIContainingFace
        | _ -> error "int_to_topology_indicator" "unknown value"

        let int_to_record_type (i:int) = match i with 
        | 10 -> RGenInfo
        | 20 -> RGeoReference
        | 30 -> RDSHistory 
        | 40 -> RDSAccuracy
        | 50 -> RCatalogDir 
        | 60 -> RCatalogCrossReference
        | 70 -> RDataDictDefn
        | 80 -> RDataDictDomain
        | 90 -> RDataDictSchema
        | _ -> RVector (int_to_vect_type i)
        

        let month_of_int (i:int) = match i with 
                | 1 -> January
                | 2 -> February
                | 3 -> March
                | 4 -> April
                | 5 -> May
                | 6 -> June
                | 7 -> July
                | 8 -> August
                | 9 -> September
                | 10 -> October
                | 11 -> November
                | 12 -> December 

        let int_to_date (i:int) = 
                let istr = string_of_int i in 
                let year = int_of_string (String.sub istr 0 4) in 
                let month = month_of_int (int_of_string (String.sub istr 4 2)) in
                let day = int_of_string (String.sub istr 6 2) in
                (month,day,year) 
       
end

