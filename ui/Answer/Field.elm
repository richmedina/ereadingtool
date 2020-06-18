module Answer.Field exposing
    ( AnswerFeedbackField
    , AnswerField
    , add_answer
    , answer
    , attributes
    , delete_answer
    , editable
    , error
    , feedback_field
    , generate_answer_field
    , get_answer_field
    , id
    , index
    , name
    , question_index
    , set_answer_correct
    , set_answer_feedback
    , set_answer_text
    , switch_editable
    , toAnswers
    , update_error
    , update_feedback_error
    , update_question_index
    )

import Answer.Model exposing (Answer)
import Array exposing (Array)
import Field


type alias AnswerFeedbackField =
    { id : String
    , editable : Bool
    , error_string : String
    , error : Bool
    }


type alias AnswerFieldAttributes =
    { id : String
    , name : String
    , editable : Bool
    , error : Bool
    , error_string : String
    , question_index : Int
    , index : Int
    }


type AnswerField
    = AnswerField Answer (Field.FieldAttributes AnswerFieldAttributes) AnswerFeedbackField


update_answer_indexes : Array AnswerField -> Array AnswerField
update_answer_indexes answer_fields =
    Array.indexedMap (\i ans -> update_answer_index ans i) answer_fields


update_question_index : AnswerField -> Int -> AnswerField
update_question_index (AnswerField answer attr feedback) i =
    AnswerField answer { attr | question_index = i } feedback


update_answer_index : AnswerField -> Int -> AnswerField
update_answer_index (AnswerField answer attr feedback) i =
    AnswerField { answer | order = i } { attr | index = i } feedback


generate_answer_feedback_field : String -> AnswerFeedbackField
generate_answer_feedback_field id =
    { id = id
    , editable = False
    , error_string = ""
    , error = False
    }


generate_answer_field : Int -> Int -> Int -> Answer -> AnswerField
generate_answer_field i j k answer =
    let
        answer_id =
            String.join "_" [ "textsection", toString i, "question", toString j, "answer", toString k ]

        answer_name =
            String.join "_" [ "textsection", toString i, "question", toString j, "correct_answer" ]
    in
    AnswerField answer
        { id = answer_id
        , input_id = String.join "_" [ answer_id, "input" ]
        , name = answer_name
        , editable = False
        , error = False
        , error_string = ""
        , question_index = j
        , index = k
        }
        (generate_answer_feedback_field <| String.join "_" [ answer_id, "feedback" ])


toAnswers : Array AnswerField -> Array Answer
toAnswers answer_fields =
    Array.map answer answer_fields


feedback_field : AnswerField -> AnswerFeedbackField
feedback_field (AnswerField _ _ feedback_field) =
    feedback_field


attributes : AnswerField -> Field.FieldAttributes AnswerFieldAttributes
attributes (AnswerField answer attr feedback_field) =
    attr


name : AnswerField -> String
name answer_field =
    let
        attrs =
            attributes answer_field
    in
    attrs.name


id : AnswerField -> String
id answer_field =
    let
        attrs =
            attributes answer_field
    in
    attrs.id


error : AnswerField -> Bool
error answer_field =
    let
        attrs =
            attributes answer_field
    in
    attrs.error


index : AnswerField -> Int
index answer_field =
    let
        attrs =
            attributes answer_field
    in
    attrs.index


answer : AnswerField -> Answer
answer (AnswerField answer _ _) =
    answer


switch_editable : AnswerField -> AnswerField
switch_editable (AnswerField answer attr feedback) =
    AnswerField answer
        { attr
            | editable =
                if attr.editable then
                    False

                else
                    True
        }
        feedback


set_answer_text : AnswerField -> String -> AnswerField
set_answer_text (AnswerField answer attr feedback) text =
    AnswerField { answer | text = text } attr feedback


set_answer_correct : AnswerField -> Bool -> AnswerField
set_answer_correct (AnswerField answer attr feedback) correct =
    AnswerField { answer | correct = correct } attr feedback


set_answer_feedback : AnswerField -> String -> AnswerField
set_answer_feedback (AnswerField answer attr feedback) new_feedback =
    AnswerField { answer | feedback = new_feedback } attr feedback


editable : AnswerField -> Bool
editable answer_field =
    let
        attrs =
            attributes answer_field
    in
    attrs.editable


question_index : AnswerField -> Int
question_index answer_field =
    let
        attrs =
            attributes answer_field
    in
    attrs.question_index


get_answer_field : Array AnswerField -> Int -> Maybe AnswerField
get_answer_field answer_fields index =
    Array.get index answer_fields


add_answer : Array AnswerField -> AnswerField -> AnswerField -> Array AnswerField
add_answer answer_fields answer_field new_answer_field =
    let
        last_elem_index =
            Array.length answer_fields

        begin =
            Array.slice 0 (index answer_field + 1) answer_fields

        end =
            Array.slice (index new_answer_field) last_elem_index answer_fields
    in
    update_answer_indexes <|
        Array.append (Array.push new_answer_field begin) end


delete_answer : Array AnswerField -> AnswerField -> Array AnswerField
delete_answer answer_fields answer_field =
    update_answer_indexes <|
        Array.filter (\ans -> index ans /= index answer_field) answer_fields


update_error : AnswerField -> String -> AnswerField
update_error (AnswerField answer attr feedback) error_string =
    AnswerField answer { attr | error = True, error_string = error_string } feedback


update_feedback_error : AnswerField -> String -> AnswerField
update_feedback_error (AnswerField answer attr feedback) error_string =
    switch_editable (AnswerField answer attr { feedback | error = True, error_string = error_string })
