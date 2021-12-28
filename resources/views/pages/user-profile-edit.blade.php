@extends('layouts.navbar')

@section('content')

<!DOCTYPE html>

<html lang="{{ app()->getLocale() }}">
<head>
    @if(Auth::check())
    <title>{{$user->username}} Profile</title>
    @endif
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <meta charset="utf-8">
    <style>
        .path-on-user-page {
            font-size: larger;
            margin: 25px 0px 0px 100px;
            display: flex;
            flex-direction: row;
        }

        .path-on-user-page a {
            color: black;
            text-decoration: none;
        }

        .edit-icon {
            margin-left: 75px;
        }

        .user-profile-picture-and-header-info {
            display: flex;
            flex-direction: row;
            margin: 15px 0px 0px 50px;
        }

        .user-info {
            display: flex;
            flex-direction: row;
        }

        .user-profile-picture img {
            height: 250px;
            width: 250px;
            border-radius: 125px;
        }

        .user-header-info {
            margin: 15px 0px 0px 25px;
        }

        .user-fullname input {
            width: 275px;
        }

        .user-description {
            margin: 30px 0px 0px 50px;
        }

        .user-bio input {
            height: 140px;
            width: 400px;
        }

        .user-status select{
            width: 150px;
        }

        .user-location {
            margin-top: 35px;
        }


    </style>
</head>

<body>
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    <div class="path-on-user-page">
        @if(Auth::check())
        <p><a href="{{ route('home')}}">Home</a> -> Users -> {{$user->username}}</p>
        @endif
    </div>
    <div class="main-container">
        <div class="user-info">
            <div class="user-profile-picture-and-header-info">
                <div class="user-profile-picture">
                    <div class="media">
                        <div class="media-bottom">
                            <img class="media-object" src="https://previews.123rf.com/images/kritchanut/kritchanut1406/kritchanut140600093/29213195-male-silhouette-avatar-profile-picture.jpg" alt="Profile Picture">
                        </div>
                    </div>
                </div>
                <div class="user-header-info">
                    <div class="media-body">
                        <p>Username</p>
                        <h4 class="media-heading user-name"><input class="textbox" type="text" value="{{$user->username}}" minlength="3" maxlength="25"></h4>
                        <br>
                        <p>Full Name</p>
                        <p class="user-fullname"><input class="textbox" type="text" value="{{$user->full_name}}" maxlength="100"></p>
                        <br>
                        <p>Status</p>
                        <p class="user-status">
                            <select class="user-status-dropdown">
                                <option value="active" selected>Active</option>
                                <option value="inactive">Inactive</option>
                                <option value="idle">Idle</option>
                                <option value="doNotDisturb">Do Not Disturb</option>
                            </select>
                        </p>
                    </div>
                </div>
            </div>

            <div class="user-description">
                <div class="user-bio">
                    <p>Bio</p>
                    <p><input class="textbox" type="text" value="{{$user->bio}}" maxlength="300"></p>
                </div>
                <div class="user-location">
                    <p>Location</p>
                    <p><input class="textbox" type="text" value="{{$user->location}}" maxlength="100"></p>
                </div>
                <!-- <div class="user-socials">
                    <p>Só tenho twitter e não é para ti</p>
                </div> -->

            </div>
        </div>
    </div>
    @include('layouts.footerbar')
</body>
</html>
@endsection