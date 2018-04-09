import Html exposing (..)
import Html.Attributes exposing (classList, attribute)

import Html.Events exposing (onClick, onBlur, onInput, onMouseOver, onCheck, onMouseOut, onMouseLeave)

import Array exposing (Array)

import Http
import HttpHelpers exposing (post_with_headers)

import Dict exposing (Dict)
import Debug

import Model exposing (Text, Question, Answer, textsDecoder, textEncoder, textDecoder, textCreateRespDecoder,
  TextCreateResp)

import Ports exposing (selectAllInputText)

import Config exposing (text_api_endpoint)

import Flags exposing (CSRFToken, Flags)

type Field = Text TextField | Question QuestionField | Answer AnswerField

type Msg = ToggleEditableField Field | Hover Field | UnHover Field | ToggleQuestionMenu QuestionField
  | UpdateTitle String
  | UpdateSource String
  | UpdateDifficulty String
  | UpdateBody String
  | UpdateQuestionBody QuestionField String
  | UpdateAnswerText QuestionField AnswerField String
  | UpdateAnswerCorrect QuestionField AnswerField Bool
  | UpdateAnswerFeedback QuestionField AnswerField String
  | AddQuestion
  | DeleteQuestion Int
  | SubmitQuiz
  | Submitted (Result Http.Error TextCreateResp)

type alias TextField = {
    id : String
  , editable : Bool
  , hover : Bool
  , index : Int }

type alias AnswerField = {
    id : String
  , editable : Bool
  , hover : Bool
  , answer : Answer
  , question_field_index : Int
  , index : Int }

type alias QuestionField = {
    id : String
  , editable : Bool
  , hover : Bool
  , question : Question
  , answer_fields : Array AnswerField
  , menu_visible : Bool
  , index : Int }


type alias Model = {
    text : Text
  , flags : Flags
  , success_msg : Maybe String
  , error_msg : Maybe String
  , text_fields : Array TextField
  , question_fields : Array QuestionField }

type alias Filter = List String

new_text : Text
new_text = {
    id = Nothing
  , title = "title"
  , created_dt = Nothing
  , modified_dt = Nothing
  , source = "source"
  , difficulty = ""
  , question_count = 0
  , body = "text" }


new_question : Int -> Question
new_question i = {
    id = Nothing
  , text_id = Nothing
  , created_dt = Nothing
  , modified_dt = Nothing
  , body = "Click to write the question text."
  , order = i
  , answers = generate_answers 4
  , question_type = "main_idea" }


question_difficulties : List (String, String)
question_difficulties = [
    ("intermediate_mid", "Intermediate-Mid")
  , ("intermediate_high", "Intermediate-High")
  , ("advanced_low", "Advanced-Low")
  , ("advanced_mid", "Advanced-Mid") ]


initial_questions : Array Question
initial_questions = Array.fromList [(new_question 0)]

init : Flags -> (Model, Cmd Msg)
init flags = ({
        text=new_text
      , error_msg=Nothing
      , success_msg=Nothing
      , flags=flags
      , text_fields=(Array.fromList [
          {id="title", editable=False, hover=False, index=0}
        , {id="source", editable=False, hover=False, index=1}
        , {id="difficulty", editable=False, hover=False, index=2}
        , {id="body", editable=False, hover=False, index=3} ])
      , question_fields=(Array.indexedMap generate_question_field initial_questions)
  }, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

add_new_question : Array QuestionField -> Array QuestionField
add_new_question fields = let arr_len = Array.length fields in
  Array.push (generate_question_field arr_len (new_question arr_len)) fields

delete_question : Int -> Array QuestionField -> Array QuestionField
delete_question index fields =
     Array.indexedMap (\i field ->
       { field | index = i
       , answer_fields = Array.map (\a -> {a | question_field_index = i }) field.answer_fields
     })
  <| Array.filter (\field -> field.index /= index) fields

generate_question_field : Int -> Question -> QuestionField
generate_question_field i question = {
    id=(String.join "_" ["question", toString i])
  , editable=False
  , hover=False
  , question=question
  , answer_fields=(Array.indexedMap (generate_answer_field i question) question.answers)
  , menu_visible=True
  , index=i }

generate_answer_field : Int -> Question -> Int -> Answer -> AnswerField
generate_answer_field i question j answer = {
    id=(String.join "_" ["question", toString i, "answer", toString j])
  , editable=False
  , hover=False
  , answer = answer
  , question_field_index = i
  , index=j }

generate_answer : Int -> Answer
generate_answer i = {
    id=Nothing
  , question_id=Nothing
  , text=String.join " " ["Click to write choice", toString i]
  , correct=False
  , order=i
  , feedback="" }

generate_answers : Int -> Array Answer
generate_answers n =
     Array.fromList
  <| List.map generate_answer
  <| List.range 1 n

toggle_editable : { a | hover : Bool, index : Int, editable : Bool }
    -> Array { a | index : Int, editable : Bool, hover : Bool }
    -> Array { a | index : Int, editable : Bool, hover : Bool }
toggle_editable field fields =
  Array.set field.index { field |
    editable = (if field.editable then False else True), hover=False}
  fields

set_hover
    : { a | hover : Bool, index : Int }
    -> Bool
    -> Array { a | index : Int, hover : Bool }
    -> Array { a | index : Int, hover : Bool }
set_hover field hover fields = Array.set field.index { field | hover = hover } fields

update_answer : AnswerField -> Array QuestionField -> Array QuestionField
update_answer answer_field question_fields =
  case Array.get answer_field.question_field_index question_fields of
    Just question_field ->
      let new_question_field = { question_field
      | answer_fields = Array.set answer_field.index answer_field question_field.answer_fields } in
      Array.set new_question_field.index new_question_field question_fields
    _ -> question_fields

update_question_field : QuestionField -> Array QuestionField -> Array QuestionField
update_question_field new_question_field question_fields =
  Array.set new_question_field.index new_question_field question_fields

post_toggle_field : { a | id: String, hover : Bool, index : Int, editable : Bool } -> Cmd Msg
post_toggle_field field = if not field.editable then (selectAllInputText field.id) else Cmd.none

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = let text = model.text in
  case msg of
    ToggleEditableField field -> case field of
      Text text_field -> ({ model | text_fields = toggle_editable text_field model.text_fields }
                     , post_toggle_field text_field)
      Question question_field -> ({ model | question_fields = toggle_editable question_field model.question_fields }
                         , post_toggle_field question_field)
      Answer answer_field ->
        let new_answer_field = { answer_field
          | editable = (if answer_field.editable then False else True)
          , hover = False } in
        ({ model | question_fields = update_answer new_answer_field model.question_fields}
         , post_toggle_field new_answer_field )

    Hover field -> case field of
      Text text_field -> ({ model | text_fields = set_hover text_field True model.text_fields }
                     , Cmd.none )
      Question question_field -> ({ model | question_fields = set_hover question_field True model.question_fields }
                         , Cmd.none )

      Answer answer_field -> let new_answer_field = { answer_field | hover = True } in
        ({ model | question_fields = update_answer new_answer_field model.question_fields}
         , Cmd.none )

    UnHover field -> case field of
      Text text_field -> ({ model | text_fields = set_hover text_field False model.text_fields }
                     , Cmd.none )
      Question question_field -> ({ model | question_fields = set_hover question_field False model.question_fields }
                     , Cmd.none )

      Answer answer_field -> let new_answer_field = { answer_field | hover = False } in
        ({ model | question_fields = update_answer new_answer_field model.question_fields}
         , Cmd.none )

    UpdateQuestionBody field body ->
      let question = field.question in
      let new_field = {field | question = {question | body = body} } in
        ({ model | question_fields = Array.set field.index new_field model.question_fields }, Cmd.none)

    UpdateAnswerText question_field answer_field text ->
      let answer = answer_field.answer in
      let new_answer = { answer | text = text } in
        ({ model | question_fields =
          update_answer { answer_field | answer = new_answer } model.question_fields }, Cmd.none)

    UpdateAnswerCorrect question_field answer_field correct ->
      let answer = answer_field.answer in
      let new_answer = { answer | correct = correct } in
        ({ model | question_fields =
          update_answer { answer_field | answer = new_answer } model.question_fields }, Cmd.none)

    UpdateAnswerFeedback question_field answer_field feedback ->
      let answer = answer_field.answer in
      let new_answer = { answer | feedback = feedback } in
        ({ model | question_fields =
          update_answer { answer_field | answer = new_answer } model.question_fields }, Cmd.none)


    UpdateTitle title -> ({ model | text = { text | title = title }}, Cmd.none)
    UpdateSource source ->  ({ model | text = { text | source = source }}, Cmd.none)
    UpdateDifficulty difficulty -> ({ model | text = { text | difficulty = difficulty }}, Cmd.none)
    UpdateBody body -> ({ model | text = { text | body = body }}, Cmd.none)

    AddQuestion -> ({model | question_fields = add_new_question model.question_fields }, Cmd.none)
    DeleteQuestion index -> ({model | question_fields = delete_question index model.question_fields }, Cmd.none)

    SubmitQuiz -> let questions = Array.map (\q_field ->
      let answer_fields = q_field.answer_fields in
      let question = q_field.question in
       { question | answers = Array.map (\a_field -> a_field.answer) q_field.answer_fields }) model.question_fields in
       ({ model |
           error_msg = Nothing
         , success_msg = Nothing }, post_text model.flags.csrftoken model.text questions)

    Submitted (Ok text_create_resp) -> case text_create_resp.id of
       Just text_id -> ({ model
         | success_msg = Just <| String.join " " <| [" success!", toString text_id]}, Cmd.none)
       _ -> (model, Cmd.none)

    Submitted (Err err) -> case err of
      Http.BadStatus resp -> case resp of
        _ -> ({ model | error_msg = Just <| String.join " " ["something went wrong: ", resp.body]}, Cmd.none)
      Http.BadPayload err resp -> ({ model | error_msg = Just err}, Cmd.none)
      _ -> ({ model | error_msg = Just "some unspecified error"}, Cmd.none)

    ToggleQuestionMenu field ->
      let new_field = { field | menu_visible = (if field.menu_visible then False else True) } in
        ({ model | question_fields = update_question_field new_field model.question_fields }, Cmd.none)

post_text : CSRFToken -> Text -> Array Question -> Cmd Msg
post_text csrftoken text questions =
  let encoded_text = textEncoder text questions in
  let req =
    post_with_headers text_api_endpoint [Http.header "X-CSRFToken" csrftoken] (Http.jsonBody encoded_text)
    <| textCreateRespDecoder
  in
    Http.send Submitted req

main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , subscriptions = subscriptions
    , update = update
    }

view_header : Model -> Html Msg
view_header model =
    div [ classList [("header", True)] ] [
        text "E-Reader"
      , div [ classList [("menu", True)] ] [
          span [ classList [("menu_item", True)] ] [
             Html.a [attribute "href" "/admin"] [ Html.text "Quizzes" ]
          ]
        ]
    ]

view_preview : Model -> Html Msg
view_preview model =
    div [ classList [("preview", True)] ] [
      div [ classList [("preview_menu", True)] ] [
            span [ classList [("menu_item", True)] ] [
                Html.button [] [ Html.text "Preview" ]
              , Html.input [attribute "placeholder" "Search texts.."] []
            ]
      ]
    ]

view_filter : Model -> Html Msg
view_filter model = div [classList [("filter_items", True)] ] [
     div [classList [("filter", True)] ] [
         Html.input [attribute "placeholder" "Search texts.."] []
       , Html.button [] [Html.text "Create Text"]
     ]
 ]

edit_question : QuestionField -> Html Msg
edit_question question_field =
  Html.input [
      attribute "type" "text"
    , attribute "value" question_field.question.body
    , attribute "id" question_field.id
    , onInput (UpdateQuestionBody question_field)
    , onBlur (ToggleEditableField <| Question question_field)
  ] [ ]

view_question : QuestionField -> Html Msg
view_question question_field =
  div [
      attribute "id" question_field.id
    , classList [("question_item", True), ("over", question_field.hover)]
    , onClick (ToggleEditableField <| Question question_field)
    , onMouseOver (Hover <| Question question_field)
    , onMouseLeave (UnHover <| Question question_field)
  ] [
       Html.text question_field.question.body
  ]

view_answer : QuestionField -> AnswerField -> Html Msg
view_answer question_field answer_field = Html.span
  [  onClick (ToggleEditableField <| Answer answer_field)
   , onMouseOver (Hover <| Answer answer_field)
   , onMouseLeave (UnHover <| Answer answer_field) ] <|
  [   Html.text answer_field.answer.text ] ++
    (if not (String.isEmpty answer_field.answer.feedback) then [
        Html.div [classList [("answer_feedback", True)] ] [
          Html.text answer_field.answer.feedback
        ]
    ] else [])

edit_answer : QuestionField -> AnswerField -> Html Msg
edit_answer question_field answer_field = Html.span [] [
    Html.input [
        attribute "type" "text"
      , attribute "value" answer_field.answer.text
      , attribute "id" answer_field.id
      , onInput (UpdateAnswerText question_field answer_field)
    ] []
  , Html.div [] [
      Html.textarea [
          onBlur (ToggleEditableField <| Answer answer_field)
        , onInput (UpdateAnswerFeedback question_field answer_field)
        , attribute "placeholder" "Give some feedback."
        , classList [ ("answer_feedback", True) ]
      ] [Html.text answer_field.answer.feedback]
    ]
  ]

view_editable_answer : QuestionField -> AnswerField -> Html Msg
view_editable_answer question_field answer_field = div [
  classList [("answer_item", True)
            ,("over", answer_field.hover)] ] [
        Html.input [
            attribute "type" "radio"
          , attribute "name" (String.join "_" [
                "question"
              , (toString question_field.question.order), "correct_answer"])
          , onCheck (UpdateAnswerCorrect question_field answer_field)
        ] []
     ,  (case answer_field.editable of
           True -> edit_answer question_field answer_field
           False -> view_answer question_field answer_field)
  ]

view_delete_menu_item : QuestionField -> Html Msg
view_delete_menu_item field =
    Html.span [onClick (DeleteQuestion field.index)] [ Html.text "Delete" ]

view_question_type_menu_item : QuestionField -> Html Msg
view_question_type_menu_item field =
    Html.div [] [ Html.div [] [ Html.text "Main Idea | Detail" ] ]

view_menu_items : QuestionField -> List (Html Msg)
view_menu_items field = List.map (\html -> div [attribute "class" "question_menu_item"] [html]) [
      (view_delete_menu_item field)
    , (view_question_type_menu_item field)
  ]

view_question_menu : QuestionField -> List (Html Msg)
view_question_menu field = [
    div [ classList [("question_menu", True)], onClick (ToggleQuestionMenu <| field) ] [
        Html.div [] [
          Html.img [
            attribute "src" "/static/img/action_arrow.svg"
          ] []
        ], Html.div [
          classList [("question_menu_overlay", True), ("hidden", field.menu_visible)]
        ] (view_menu_items field)
    ]
  ]

view_editable_question : QuestionField -> Html Msg
view_editable_question field = div [classList [("question", True)]] <| [
       div [] [ Html.input [attribute "type" "checkbox"] [] ]
       , (case field.editable of
          True -> edit_question field
          _ -> view_question field)
    ] ++ (view_question_menu field) ++
    (Array.toList <| Array.map (view_editable_answer field) field.answer_fields)

view_add_question : Array QuestionField -> Html Msg
view_add_question fields = div [classList [("add_question", True)], onClick AddQuestion ] [ Html.text "Add question" ]

view_questions : Array QuestionField -> Html Msg
view_questions fields = div [ classList [("question_section", True)] ] <|
        (  Array.toList
        <| Array.map view_editable_question fields
        ) ++ [ (view_add_question fields) ]

get_hover : Array TextField -> Int -> Bool
get_hover fields i = case Array.get i fields of
  Just field -> field.hover
  Nothing -> False

hover_attrs : TextField -> List (Attribute Msg)
hover_attrs field = [
    classList [ ("over", field.hover) ]
  , onMouseOver (Hover <| Text field)
  , onMouseLeave (UnHover <| Text field)]

text_property_attrs : TextField -> List (Attribute Msg)
text_property_attrs field = [onClick (ToggleEditableField <| Text field)] ++ (hover_attrs field)

view_title : Model -> TextField -> Html Msg
view_title model field = Html.div (text_property_attrs field) [
    Html.text "Title: "
  , Html.text model.text.title
  ]

edit_title : Model -> TextField -> Html Msg
edit_title model field = Html.input [
        attribute "type" "text"
      , attribute "value" model.text.title
      , attribute "id" "title"
      , onInput UpdateTitle
      , onBlur (ToggleEditableField <| Text field) ] [ ]

view_source : Model -> TextField -> Html Msg
view_source model field = Html.div (text_property_attrs field) [
     Html.text "Source: "
   , Html.text model.text.source
  ]

edit_source : Model -> TextField -> Html Msg
edit_source model field = Html.input [
        attribute "type" "text"
      , attribute "value" model.text.source
      , attribute "id" "source"
      , onInput UpdateSource
      , onBlur (ToggleEditableField <| Text field) ] [ ]

edit_difficulty : Model -> TextField -> Html Msg
edit_difficulty model field = Html.div [] [
      Html.text "Difficulty:  "
    , Html.select [
         onInput UpdateDifficulty ] [
        Html.optgroup [] (List.map (\(k,v) ->
          Html.option (if v == model.text.difficulty then [attribute "selected" ""] else []) [Html.text v])
          question_difficulties
        )
       ]
  ]

view_body : Model -> TextField -> Html Msg
view_body model field = Html.div (text_property_attrs field) [
    Html.text "Text: "
  , Html.text model.text.body ]

edit_body : Model -> TextField -> Html Msg
edit_body model field = Html.textarea [
        onInput UpdateBody
      , attribute "id" field.id
      , onBlur (ToggleEditableField <| Text field) ] [ Html.text model.text.body ]

view_editable_field : Model -> Int -> (TextField -> Html Msg) -> (TextField -> Html Msg) -> Html Msg
view_editable_field model i view edit = case Array.get i model.text_fields of
   Just field -> case field.editable of
     True -> edit field
     _ -> view field
   _ -> Html.text ""

view_create_text : Model -> Html Msg
view_create_text model = div [ classList [("text_properties", True)] ] [
      div [ classList [("text_property_items", True)] ] [
          view_editable_field model 0 (view_title model) (edit_title model)
        , view_editable_field model 1 (view_source model) (edit_source model)
        , view_editable_field model 2 (edit_difficulty model) (edit_difficulty model)
      ]
      , div [ classList [("body",True)] ]  [ view_editable_field model 3 (view_body model) (edit_body model) ]
  ]

view_msg : Maybe String -> Html Msg
view_msg msg = let msg_str = (case msg of
        Just str ->
          String.join " " [" ", str]
        _ -> "") in Html.text msg_str


view_submit : Model -> Html Msg
view_submit model = Html.div [classList [("submit_section", True)]] [
    Html.div [attribute "class" "submit", onClick SubmitQuiz] [
        Html.text "Create Quiz "
      , view_msg model.error_msg
      , view_msg model.success_msg
    ]
  ]

view : Model -> Html Msg
view model = div [] [
      (view_header model)
    , (view_preview model)
    , (view_create_text model)
    , (view_questions model.question_fields)
    , (view_submit model)
  ]
