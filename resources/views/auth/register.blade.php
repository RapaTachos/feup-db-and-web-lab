<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">

    <title>iNeedHelp | Sign up</title>

    <link rel="shortcut icon" href="{{ asset('assets/favicon.png') }}" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3"
          crossorigin="anonymous"
    >
</head>

<body>
<div class="container mt-5">

    <a href="{{route('home')}}">
        <img src="{{ asset('assets/logo.png') }}" class="d-block mx-auto" style="max-height: 12rem" alt="logo">
    </a>

    <form
        action="{{ route('register') }}"
        method="post"
        class="row justify-content-center g-3 mx-auto"
        style="max-width: 32rem"
    >
        @csrf

        <div class="text-center">
            {{--            <h1>iNeedHelp</h1>--}}
            <h2>Sign Up</h2>
        </div>
        <div class="col-12">
            <label for="username" class="form-label">Username</label>
            <input
                name="username"
                type="text"
                minlength="3"
                value="{{ old('username') }}"
                class="form-control @error('email') is-invalid @enderror"
                placeholder="JDean72"
                required
            >

            @error('username')
            <span class="text-danger">{{ $message }}</span>
            @enderror
        </div>

        <div class="col">
            <label for="full_name" class="form-label">Full Name</label>
            <small class="form-text text-muted">Optional</small>
            <input
                name="full_name"
                type="text"
                value="{{ old('full_name') }}"
                class="form-control"
                placeholder="John Dean"
            >

        </div>

        <div class="col-12">
            <label for="email" class="form-label">Email</label>
            <input
                name="email"
                type="email"
                value="{{ old('email') }}"
                class="form-control @error('email') is-invalid @enderror"
                placeholder="name@example.com"
                required
            >
            @error('email')
            <span class="text-danger">{{ $message }}</span>
            @enderror
        </div>

        <div class="col-6">
            <label for="password" class="form-label">Password</label>
            <input
                name="password"
                type="password"
                class="form-control @error('password') is-invalid @enderror"
                required
            >
            @error('password')
            <span class="text-danger">{{ $message }}</span>
            @enderror
        </div>

        <div class="col-6">
            <label for="password_confirmation" class="form-label">Confirm Password</label>
            <input
                name="password_confirmation"
                type="password"
                class="form-control @error('password_confirmation') is-invalid @enderror"
                required
            >

            @error('password_confirmation')
            <span class="text-danger">{{ $message }}</span>
            @enderror
        </div>
        <div class="col d-grid">
            <button type="submit" class="btn btn-primary mt-1">Sign up</button>
        </div>

        <a class="text-center" href="{{route('login')}}">Already have an account? Sign in</a>

        <p class="text-muted mt-4">?? LBAW2153 {{ date('Y') }}</p>
    </form>
</div>
</body>
</html>



