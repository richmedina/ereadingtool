module TextReader.Model exposing (..)

import Dict exposing (Dict)

import TextReader.TextWord

import Text.Translations exposing (Id, Phrase, Instance)

import TextReader.Text.Model exposing (Text)
import TextReader.Section.Model exposing (Section)
import TextReader.Answer.Model exposing (TextAnswer, Answer, AnswerCorrect)

import TextReader exposing (TextItemAttributes, WebSocketAddress)

import Profile.Flags as Flags

import User.Profile


type Progress = Init | ViewIntro | ViewSection Section | Complete TextScores

type alias Exception = { code: String, error_msg: String }

type alias Gloss = Dict String Bool
type alias Flashcards = Dict String Bool

type TextReaderWord = TextReaderWord Id Instance Phrase (Maybe TextReader.TextWord.TextWord)

new : Id -> Instance -> Phrase -> Maybe TextReader.TextWord.TextWord -> TextReaderWord
new id instance phrase text_word =
  TextReaderWord id instance phrase text_word

identifier : TextReaderWord -> Id
identifier (TextReaderWord id _ _ _) =
  id

textWord : TextReaderWord -> Maybe TextReader.TextWord.TextWord
textWord (TextReaderWord _ _ _ text_word) =
  text_word

instance : TextReaderWord -> Instance
instance (TextReaderWord _ instance _ _) =
  instance

phrase : TextReaderWord -> Phrase
phrase (TextReaderWord _ _ phrase _) =
  phrase

gloss : TextReaderWord -> Gloss -> Gloss
gloss reader_word gloss =
  Dict.insert (identifier reader_word) True (Dict.insert (String.toLower (phrase reader_word)) True gloss)

ungloss : TextReaderWord -> Gloss -> Gloss
ungloss reader_word gloss =
  Dict.remove (identifier reader_word) (Dict.remove (String.toLower (phrase reader_word)) gloss)

glossed : TextReaderWord -> Gloss -> Bool
glossed reader_word gloss =
  Dict.member (String.toLower (phrase reader_word)) gloss

selected : TextReaderWord -> Gloss -> Bool
selected reader_word gloss =
  Dict.member (identifier reader_word) gloss

type CmdReq =
    NextReq
  | PrevReq
  | AnswerReq TextAnswer
  | AddToFlashcardsReq TextReaderWord
  | RemoveFromFlashcardsReq TextReaderWord

type CmdResp =
    StartResp Text
  | InProgressResp Section
  | CompleteResp TextScores
  | AddToFlashcardsResp TextReader.TextWord.TextWord
  | RemoveFromFlashcardsResp TextReader.TextWord.TextWord
  | ExceptionResp Exception

type alias TextScores = {
    num_of_sections: Int
  , complete_sections: Int
  , section_scores: Int
  , possible_section_scores: Int }


type alias Flags = Flags.Flags { text_id : Int, text_reader_ws_addr: WebSocketAddress }

type alias Model = {
    text : Text
  , profile : User.Profile.Profile
  , progress: Progress
  , gloss : Gloss
  , exception : Maybe Exception
  , flags : Flags }
