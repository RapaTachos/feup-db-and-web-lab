<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Answer;
use Illuminate\Support\Facades\Auth;

class AnswerController extends Controller
{
    protected function create_answer(Request $request, int $questionId)
    {
        // find question com $questionId e $userID
        // if match, return error
        // else, post new answer

        $exists = Answer::where('question_id', $questionId)->where('user_id', Auth::user()->id)->exists();

        if($exists){
            //Error
            return redirect()->back()->withErrors(['You have already posted an answer on this question!']);
        }
        
        $this->validate($request, [
            'content' => 'required|string|min:10',
        ]);

        $answerCreated = Answer::create([
            'user_id' => Auth::user()->id,
            'question_id' => $questionId,
            'content' => $request->input('content'),
        ]);
        return redirect()->back()->withSuccess('Your answer was successfully posted!');

    }

    public function review(Request $request, Answer $answer, string $type)
    {
        if ($answer->reviewedBy($request->user())) {
            // client wants to change review type
            $this->unreview($request, $answer);
        }

        $answer->reviews()->create([
            'user_id' => $request->user()->id,
            'type' => $type,
        ]);

        return back();
    }

    public function unreview(Request $request, Answer $answer)
    {
        $request->user()->answerReviews()->where('answer_id', $answer->id)->delete();
        return back();
    }

    public function delete(Request $request, Answer $answer){
        $answer->comments()->delete();
        $answer->delete();
        return back();
    }
}
