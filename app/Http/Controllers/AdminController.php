<?php

namespace App\Http\Controllers;

use App\Models\Question;
use App\Models\Tag;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    //
    function show(Request $request, $category){
        switch ($category) {
            case 'users':
                $users = User::orderBy('id')->paginate(10);
                return view('pages.adminUsers', ['users'=> $users]);
                break;
            case 'questions':
                $questions = Question::orderBy('id')->paginate(10);
                return view('pages.adminQuestions', ['questions'=> $questions]);
                break;
            case 'tags':
                $tags = Tag::orderBy('id')->paginate(10);
                return view('pages.adminTags', ['tags'=> $tags]);
                break;
            default:
                # code...
                break;
        }

    }
    
    function changeBlock(Request $request, User $user){

        $user->is_blocked = !$user->is_blocked;
        $user->save();

        // $users = User::paginate(10);
        // return view('pages.admin', ['users'=> $users]);
        return back();
    }

    function deleteUser(Request $request, User $user){
        $user->delete();
        return back();
    }


    function deleteQuestion(Request $request, Question $question){
        $question->delete();
        return back();
    }

    function deleteTag(Request $request, Tag $tag){
        dd("Working on...delete tag!");
    }

}
