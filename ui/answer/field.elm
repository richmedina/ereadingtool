module Answer.Field exposing (AnswerField, AnswerFeedbackField, generate_answer_field, update_question_index
  , index, question_index, switch_editable, hover)

import Field
import Answer.Model exposing (Answer)

type alias AnswerFeedbackField = {
    id : String
  , editable : Bool
  , error : Bool }

type alias AnswerFieldAttributes = {
    id: String
  , editable: Bool
  , hover: Bool
  , error: Bool
  , question_index: Int
  , index: Int }

type AnswerField = AnswerField Answer (Field.FieldAttributes AnswerFieldAttributes) AnswerFeedbackField

update_question_index : AnswerField -> Int -> AnswerField
update_question_index (AnswerField answer attr feedback) i = AnswerField answer { attr | question_index = i} feedback

generate_answer_feedback_field : String -> AnswerFeedbackField
generate_answer_feedback_field id = {
    id = id
  , editable = False
  , error = False }

generate_answer_field : Int -> Int -> Answer -> AnswerField
generate_answer_field i j answer = let
    answer_id = String.join "_" ["question", toString i, "answer", toString j]
  in
    AnswerField answer {
      id = answer_id
    , editable = False
    , hover = False
    , error = False
    , question_index = i
    , index = j } (generate_answer_feedback_field <| String.join "_" [answer_id, "feedback"])

attributes : AnswerField -> Field.FieldAttributes AnswerFieldAttributes
attributes (AnswerField answer attr feedback_field) = attr

index : AnswerField -> Int
index answer_field = let attrs = (attributes answer_field) in attrs.index

switch_editable : AnswerField -> AnswerField
switch_editable (AnswerField answer attr feedback) =
  AnswerField answer { attr | editable = (if attr.editable then False else True), hover=False } feedback

hover : AnswerField -> Bool -> AnswerField
hover (AnswerField answer attr feedback_field) hover = AnswerField answer { attr | hover = hover } feedback_field

question_index : AnswerField -> Int
question_index answer_field = let attrs = (attributes answer_field) in attrs.question_index
