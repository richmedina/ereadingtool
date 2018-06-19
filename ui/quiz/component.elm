module Quiz.Component exposing (QuizComponent, emptyQuizComponent, text_components, set_text_components
  , quiz, set_quiz_attribute, init, update_quiz_errors, reinitialize_ck_editors, set_title_editable
  , set_intro_editable, QuizViewParams, quiz_fields, add_tag, remove_tag, tags)

import Quiz.Model as Quiz exposing (Quiz)
import Quiz.Field exposing (QuizFields, init_quiz_fields, QuizIntro, QuizTitle, QuizTags)

import Text.Component.Group exposing (TextComponentGroup)

import Dict exposing (Dict)
import Ports exposing (ckEditor, ckEditorSetHtml, CKEditorID, CKEditorText, addClassToCKEditor, selectAllInputText)

type alias QuizAttributeName = String

type alias QuizViewParams = {
    quiz: Quiz
  , quiz_component: QuizComponent }

type alias QuizTags = Dict String String

type QuizComponent = QuizComponent Quiz QuizFields QuizTags TextComponentGroup

init : Quiz -> QuizComponent
init quiz =
  QuizComponent quiz init_quiz_fields (Debug.log "tags" (tags_to_dict quiz.tags)) (Text.Component.Group.fromTexts quiz.texts)

quiz : QuizComponent -> Quiz
quiz (QuizComponent quiz _ quiz_tags component_group) =
  Quiz.set_tags (Quiz.set_texts quiz (Text.Component.Group.toTexts component_group)) (Just <| Dict.keys quiz_tags)

quiz_fields : QuizComponent -> QuizFields
quiz_fields (QuizComponent _ quiz_fields _ _) =
  quiz_fields

set_quiz_fields : QuizComponent -> QuizFields -> QuizComponent
set_quiz_fields quiz_component quiz_fields =
  quiz_component

set_intro_editable : QuizComponent -> Bool -> QuizComponent
set_intro_editable (QuizComponent quiz quiz_fields quiz_tags component_group) editable =
  let
    (Quiz.Field.QuizIntro intro_field_attrs) = Quiz.Field.intro quiz_fields
    new_quiz_fields = Quiz.Field.set_intro quiz_fields { intro_field_attrs | editable = editable }
  in
    QuizComponent quiz new_quiz_fields quiz_tags component_group

set_title_editable : QuizComponent -> Bool -> QuizComponent
set_title_editable (QuizComponent quiz quiz_fields quiz_tags component_group) editable =
  let
    (Quiz.Field.QuizTitle title_field_attrs) = Quiz.Field.title quiz_fields
    new_quiz_fields = Quiz.Field.set_title quiz_fields { title_field_attrs | editable = editable }
  in
    QuizComponent quiz new_quiz_fields quiz_tags component_group

text_components : QuizComponent -> TextComponentGroup
text_components (QuizComponent _ _ _ components) =
  components

set_text_components : QuizComponent -> TextComponentGroup -> QuizComponent
set_text_components (QuizComponent quiz fields quiz_tags _) new_components =
  QuizComponent quiz fields quiz_tags new_components

set_quiz_attribute : QuizComponent -> QuizAttributeName -> String -> QuizComponent
set_quiz_attribute ((QuizComponent quiz fields quiz_tags components) as quiz_component) attr_name value =
  case attr_name of
    "title" -> QuizComponent { quiz | title = value } fields quiz_tags components
    "introduction" -> QuizComponent { quiz | introduction = value } fields quiz_tags components
    _ -> quiz_component

emptyQuizComponent : QuizComponent
emptyQuizComponent =
  QuizComponent Quiz.new_quiz init_quiz_fields (Dict.fromList []) (Text.Component.Group.new_group)

reinitialize_ck_editors : QuizComponent -> Cmd msg
reinitialize_ck_editors ((QuizComponent quiz fields quiz_tags components) as quiz_component) =
  let
    text_component_group = text_components quiz_component
  in
    Cmd.batch [
      Cmd.batch [ckEditor "quiz_introduction", ckEditorSetHtml ("quiz_introduction", quiz.introduction)]
    , Text.Component.Group.reinitialize_ck_editors text_component_group ]

update_quiz_errors : QuizComponent -> Dict String String -> QuizComponent
update_quiz_errors quiz_component errors =
  let
    _ = (Debug.log "quiz errors" errors)
    new_text_components =
      Text.Component.Group.update_errors (text_components quiz_component) errors
  in
    (set_text_components quiz_component new_text_components)

tags_to_dict : Maybe (List String) -> Dict String String
tags_to_dict tags =
  case tags of
    Just tags_list ->
      Dict.fromList <| List.map (\tag -> (tag, tag)) tags_list
    _ -> Dict.fromList []

tags : QuizComponent -> Dict String String
tags (QuizComponent _ _ quiz_tags _) =
  quiz_tags

add_tag : QuizComponent -> String -> QuizComponent
add_tag ((QuizComponent quiz fields quiz_tags components) as quiz_component) tag =
  QuizComponent quiz fields (Dict.insert tag tag quiz_tags) components

remove_tag : QuizComponent -> String -> QuizComponent
remove_tag ((QuizComponent quiz fields quiz_tags components) as quiz_component) tag =
  QuizComponent quiz fields (Dict.remove tag quiz_tags) components
