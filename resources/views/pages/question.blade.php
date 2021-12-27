@extends('layouts.navbar')

@section('content')
<style>
    /* body {
        font-family: Arial, Helvetica, sans-serif;
        margin: 0;
    } */
    #your-answer {
        resize: none;
    }

</style>
    <section class="pt-4">
        <div class="container">
            <div class="d-flex flex-column">
                <h1 class="display-5">{{ $question->title }}</h1>

                <div class="d-flex">
                    <div class="text-center pt-2">
                        @php
                            $liked = auth()->check() ? $question->likedBy(auth()->user()) : false;
                            $disliked = auth()->check() ? $question->dislikedBy(auth()->user()) : false;
                        @endphp
                        <form action="{{ route('question.review', [$question->id, 'like']) }}" method="post">
                            @csrf
                            @if ($liked)
                                @method('DELETE')
                            @endif
                            <button type="submit" class="btn"><i
                                    class="fs-4 bi bi-chevron-up @if ($liked)) text-primary @endif"></i></button>
                        </form>
                        <div>{{ $question->score() }}</div>

                        <form action="{{ route('question.review', [$question->id, 'dislike']) }}" method="post">
                            @csrf
                            @if ($disliked)
                                @method('DELETE')
                            @endif
                            <button type="submit" class="btn">
                                <i class="fs-4 bi bi-chevron-down @if ($disliked) text-danger @endif"></i>
                            </button>
                        </form>
                    </div>

                    <div class="flex-grow-1 p-4">
                        <p>{{ $question->content }}</p>

                        <div class="d-flex justify-content-end pt-2">
                            <div style="min-width: 18rem">
                                <div>
                                    Asked {{ \Carbon\Carbon::parse($question->created_at)->toDayDateTimeString() }}
                                </div>
                                <a class="text-decoration-none"
                                    href="{{ '/users/' . $question->user->username }}">{{ $question->user->username }}
                                </a>
                            </div>
                        </div>

                        @each('partials.comment',$question->comments, 'comment')
                    </div>
                </div>
            </div>
            <hr>

            <p class="fs-4">{{ $question->answers->count() }}
                {{ Str::plural('Answer', $question->answers->count()) }}</p>

            @each('partials.answer', $question->answers, 'answer')

            @if (Auth::check())

                <form style="width:1000px;  margin:auto" action="{{ route('new-answer', ['id'=>$question->id]) }}" method="post">
                    @csrf
                    {{-- <div>
                        <label for="content">Content</label>
                        <input name="content" type="text" id="content" class="form-control "
                            placeholder="Here you can explain in depth what is the problem.Try to include prints, pictures, graphs..."
                            required>
                        @error('content')
                            <span class="text-danger">{{ $message }}</span>
                        @enderror
                    </div> --}}
                    <div class="form-group">
                        <label for="your-answer">Your Answer</label>
                        <textarea class="form-control" id="your-answer" rows="6" name="content"></textarea>
                        @error('content')
                            <span class="text-danger">{{ $message }}</span>
                        @enderror
                    </div>
                    <div>
                        <button type="submit" class="btn btn-primary mt-1">Post Answer</button>
                    </div>
                </form>
            @else

            @endif
        </div>
    </section>


    @include('layouts.footerbar')

@endsection
