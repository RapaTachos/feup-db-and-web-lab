<?php

namespace App\Http\Controllers;

use App\Models\Question;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class QuestionController extends Controller
{
    public function show($id)
    {
        $question = Question::find($id);
        return view('pages.question', ['question' => $question]);
    }

    public function browse()
    {
        $new_questions = Question::orderBy('created_at', 'desc')->limit(10)->get();
        $top_questions = Question::withCount('likes')->orderBy('likes_count','desc')   ->limit(10)->get();
        return view('pages.questions', ['new_questions' => $new_questions, 'top_questions' => $top_questions]);
    }

    public function show_create()
    {
        return view('pages.new-question');
    }

    protected function create_question(Request $request): Question
    {
        $this->validate($request, [
            'title' => 'required|string|min:10',
            'content' => 'required|string|min:10',
        ]);

        return Question::create([
            'user_id' => Auth::user()->id,
            'title' => $request->input('title'),
            'content' => $request->input('content'),
        ]);
    }


}
