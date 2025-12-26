% BSC IT AI Guidance System OUSL
% --- Main Start ---
start :-
    writeln('|-------------------------------------------------------------------------------|'),
    writeln('|--- Welcome to the BSC IT AI Guidance System OUSL ---|'),
    writeln('|-------------------------------------------------------------------------------|'),
    write('Choose your interface type ( console(c) or gui(g)): '),
    read_line_to_string(user_input, RawInput),
    string_lower(RawInput, Choice),
    (   (Choice == "console" ; Choice == "c")
    ->  start_console
    ;   (Choice == "gui" ; Choice == "g")
    ->  start_gui
    ;   writeln('Invalid Your Enter! Please run start again and type "console(c)" or "gui(g)".')
    ).


% *********************************--- CONSOLE MODE ---***************************************
start_console :-
    run_guidance_loop.

run_guidance_loop :-
    writeln('\n|--------------------------------------------------------|'),
    writeln('|--- BSC IT AI Guidance System OUSL : Console Mode ---|'),
    writeln('|--------------------------------------------------------|\n'),
    al_status(StartNode),
    dream_job(GoalNode),
    algorithm(Algorithm),
    writeln('\n--- Searching for your path... ---'),
    run_search(StartNode, GoalNode, Algorithm),
    ask_to_repeat.

ask_to_repeat :-
    nl,
    write('Do you want to run another search? (yes/no): '),
    read_line_to_string(user_input, RawInput),
    string_lower(RawInput, Input),
    (   (Input == "yes" ; Input == "y") -> nl, run_guidance_loop
    ;   (Input == "no" ; Input == "n") -> writeln('Thank you for using the BSC IT AI Guidance System OUSL. Goodbye !'), !
    ;   writeln('Invalid input. Please type "yes" or "no".'),
    ask_to_repeat
    ).
    
al_status(StartNode) :-
    write('Did you pass or fail your A/L exam? (type pass or fail): '),
    read_line_to_string(user_input, Input),
    string_lower(Input, Choice),
    (   (Choice == "pass" ; Choice == "p") -> StartNode = al_pass
    ;   (Choice == "fail" ; Choice == "f") -> StartNode = al_fail
    ;   writeln('Invalid input. Please type "pass" or "fail".'),
    al_status(StartNode)
    ).

dream_job(GoalNode) :-
    nl, writeln('What is your dream job?'),
    writeln('  1: Software Engineer'), writeln('  2: Cybersecurity Engineer'), writeln('  3: AI Engineer'), writeln('  4: UI/UX Designer'),
    write('Please enter the number or full name: '),
    read_line_to_string(user_input, Input),
    (   job_name(Input, GoalNode) -> true
    ;   writeln('Invalid job selection. Please try again.'),
    dream_job(GoalNode)
    ).

algorithm(Algorithm) :-
    nl, write('Which algorithm is used?(All_Path(dfs),Best_path(bfs),Optimal_Path(a_star)): '),
    read_line_to_string(user_input, Input),
    string_lower(Input, LowerInput),
    (   (member(LowerInput, ["dfs", "bfs", "a_star"])) -> atom_string(Algorithm, LowerInput)
    ;   writeln('Invalid algorithm. Please type "All_Path (dfs)", "Best_path(bfs)", "Optimal_Path(a_star)".'),
    algorithm(Algorithm)
    ).

% --- Main Algorithm searching  ---

% --********* searching dfs **************------ 
run_search(StartNode, Goal, dfs) :- !,
    findall(
        path_info(PathNodes, TotalTime),
        dfs(StartNode, Goal, PathNodes, TotalTime),
        AllPaths
    ),
    print_console_dfs_results(AllPaths).

% --************ searching bfs ***********------ 
run_search(StartNode, Goal, bfs) :- !,
    (   find_bfs(StartNode, Goal, PathNodes)
    ->  print_console_single_path(PathNodes, 'N/A', bfs, 'Found 1 path using bfs:')
    ;   format('~nSorry, no path could be found using bfs.~n')
    ).

% --********** searching a_star **************------
run_search(StartNode, Goal, a_star) :- !,
    (   a_star(StartNode, Goal, PathNodes, TotalTime)
    ->  print_console_single_path(PathNodes, TotalTime, a_star, 'Found the optimal path using a_star:')
    ;   format('~nSorry, no path could be found using a_star.~n')
    ).

% --************** Dfs all path Printing ************---- 
print_console_dfs_results([]) :-
    format('~nSorry, no path could be found using dfs.~n').
print_console_dfs_results(AllPaths) :-
    length(AllPaths, NumPaths),
    format('~nFound ~w path(s) using dfs:~n', [NumPaths]),
    print_dfs_list(AllPaths, 1).

print_dfs_list([], _).
print_dfs_list([path_info(PathNodes, TotalTime) | Rest], Count) :-
    writeln('-----------------------------------------------------'),
    format('Path ~w~n', [Count]),
    writeln('-----------------------------------------------------'),
    print_steps(PathNodes, 1),
    format('~n**** Total Estimated Time: ~w months ****~n~n', [TotalTime]),
    NextCount is Count + 1,
    print_dfs_list(Rest, NextCount).

% ---*************** DFS Algorithm *************---  
dfs(Start, Goal, Path, TotalTime) :-
    dfs_accumulator(Start, Goal, [Start], RevPath, TotalTime),
    reverse(RevPath, Path).

dfs_accumulator(Goal, Goal, Visited, Visited, 0).
dfs_accumulator(Current, Goal, Visited, FinalPath, TotalTime) :-
    path(Current, NextNode, _, Time),
    \+ member(NextNode, Visited),
    dfs_accumulator(NextNode, Goal, [NextNode|Visited], FinalPath, PathTime),
    TotalTime is Time + PathTime.

%---- BFS and A star single path printing ----  
print_console_single_path(PathNodes, TotalTime, _, Header) :-
    format('~n~w~n', [Header]),
    writeln('-----------------------------------------------------'),
    print_steps(PathNodes, 1),
    (   TotalTime \== 'N/A'
    ->  format('~n**** Total Estimated Time: ~w months ****~n~n', [TotalTime])
    ;   nl
    ).

% ---********************** BFS Algorithm *******************--- 
find_bfs(Start, Goal, Path) :-
    bfs([[Start]], Goal, Path).

bfs([[Goal|Path]|_], Goal, ReversedPath) :-
    reverse([Goal|Path], ReversedPath).

bfs([Path|Paths], Goal, FinalPath) :-
    extend(Path, NewPaths),
    append(Paths, NewPaths, AllPaths),
    ( AllPaths == [] -> !, fail ; bfs(AllPaths, Goal, FinalPath) ).

extend([Node|Path], NewPaths) :-
    findall([NewNode, Node|Path],
            (path(Node, NewNode, _, _), \+ member(NewNode, [Node|Path])),
            NewPaths).

% ---******************** A Star Algorithm *********************---
heuristic(_, _, 0).
a_star(Start, Goal, Path, TotalTime) :-
    heuristic(Start, Goal, H),
    a_star_loop([f(H, 0, H, [Start])], [], Goal, RevPath, TotalTime),
    reverse(RevPath, Path).

a_star_loop([f(TotalTime, TotalTime, 0, Path)|_], _, Goal, Path, TotalTime) :-
    Path = [Goal|_], !.

a_star_loop([f(_, G, _, [Current|PathSoFar])|RestOpen], Closed, Goal, FinalPath, FinalCost) :-
    findall(
        f(F_new, G_new, H_new, [Next, Current|PathSoFar]),
        (   path(Current, Next, _, Time),
            \+ member(Next, Closed),
            G_new is G + Time,
            heuristic(Next, Goal, H_new),
            F_new is G_new + H_new
        ),
        Successors
    ),
    append(Successors, RestOpen, NewOpenUnsorted),
    sort(NewOpenUnsorted, NewOpen),
    a_star_loop(NewOpen, [Current|Closed], Goal, FinalPath, FinalCost).

a_star_loop([], _, _, _, _) :- !, fail.

% ---******************************** Helpeing for  printing path steps *****************************--- 
print_steps([_], _).
print_steps([Node1, Node2 | RestNodes], StepNum) :-
    path(Node1, Node2, Desc, Time),
    format('  ~w. ~w (~d months)~n', [StepNum, Desc, Time]),
    NextStepNum is StepNum + 1,
    print_steps([Node2 | RestNodes], NextStepNum).

% ************************--- KNOWLEDGE BASE ---*****************************************   
job_name("1", se_job).
job_name("Software Engineer", se_job).
job_name("software engineer", se_job).
job_name("2", ce_job).
job_name("Cybersecurity Engineer", ce_job).
job_name("cybersecurity engineer", ce_job).
job_name("3", ai_job).
job_name("AI Engineer", ai_job).
job_name("ai engineer", ai_job).
job_name("4", ui_job).
job_name("UI/UX Designer", ui_job).
job_name("ui/ux designer", ui_job).

path(start, al_result, 'Sit for A/L Exam', 0).
path(al_result, al_pass, 'Pass A/L', 0).
path(al_pass, select_degree, 'Select a Degree Program', 2).
path(select_degree, completed_3yr_degree, 'Complete 3 Year Degree', 36).
path(completed_3yr_degree, do_internship, 'Then,Degree duration time to Complete Internship', 0).
path(completed_3yr_degree, do_research, 'Then,Degree duration time to Complete Project', 0).
path(do_internship, special_degree_internship, 'Start Final Year for Special Degree', 12).
path(special_degree_internship, seek_employment, 'Complete Special Degree duration time to Research Project', 0).
path(do_research, special_degree_research, 'Start Final Year for Special Degree', 12).
path(special_degree_research, seek_employment, 'Complete Special Degree duration time to Research Project', 0).
path(do_internship, no_special_degree_internship, 'Graduate without a Special Degree', 0).
path(do_research, no_special_degree_research, 'Graduate without a Special Degree', 0).
path(al_result, al_fail, 'Fail A/L', 0).
path(al_fail, do_foundation, 'Complete Foundation Course', 24).
path(do_foundation, select_degree_foundation, 'Select a Degree After Foundation', 2).
path(select_degree_foundation, completed_3yr_degree_foundation, 'Complete 3 Year Degree', 36).
path(completed_3yr_degree_foundation, do_internship_foundation, 'Then, Degree duration time to Complete Internship', 0).
path(completed_3yr_degree_foundation, do_research_foundation, 'Then, Degree duration time to Complete Project', 0).
path(do_internship_foundation, special_degree_internship_foundation, 'Start Final Year for Special Degree', 12).
path(special_degree_internship_foundation, seek_employment, 'Complete Special Degree duration time to Research Project', 0).
path(do_research_foundation, special_degree_research_foundation, 'Start Final Year for Special Degree', 12).
path(special_degree_research_foundation, seek_employment, 'Complete Special Degree duration time to Research Project', 0).
path(do_internship_foundation, no_special_degree_internship_foundation, 'Graduate without a Special Degree', 0).
path(do_research_foundation, no_special_degree_research_foundation, 'Graduate without a Special Degree', 0).
path(no_special_degree_internship, seek_employment, 'Start Applying for Jobs', 2).
path(no_special_degree_research, seek_employment, 'Start Applying for Jobs', 5).
path(no_special_degree_internship_foundation, seek_employment, 'Start Applying for Jobs', 2).
path(no_special_degree_research_foundation, seek_employment, 'Start Applying for Jobs', 5).
path(seek_employment, specialize_se, 'Specialize in Software Engineering & Attend Interviews', 3).
path(seek_employment, specialize_ce, 'Specialize in Cybersecurity & Attend Interviews', 4).
path(seek_employment, specialize_ai, 'Specialize in AI/ML & Attend Interviews', 5).
path(seek_employment, specialize_ui, 'Specialize in UI/UX Design & Attend Interviews', 6).
path(specialize_se, se_job, 'Software Engineer Job!', 1).
path(specialize_ce, ce_job, 'Cybersecurity Engineer Job!', 1).
path(specialize_ai, ai_job, 'AI Engineer Job!', 1).
path(specialize_ui, ui_job, 'UI/UX Designer Job!', 1).


% *********************************--- GUI MODE ---***************************************   

% --- Required Libraries for Web Server ---
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).

start_gui :-
    write('Enter a port number for the server (e.g.: 8000 or 8001): '),
    read_line_to_string(user_input, PortString),
    atom_number(PortString, Port),
    (   integer(Port)
    ->  server(Port),
        format('~nServer is running on port ~w.~n', [Port]),
        format('Open your web browser and go to: http://localhost:~w~n', [Port])
    ;   writeln('Invalid port number. Please enter an integer.')
    ).

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% --- Define the web routes url ---
:- http_handler('/', serve_home_page, []).
:- http_handler('/find_path', find_path_handler, []).

serve_home_page(Request) :-
    http_reply_file('index.html', [], Request).

% Handler for the API call to find paths
find_path_handler(Request) :-
    http_read_json_dict(Request, In),
    (   In.al_status == "pass" ->  StartNode = al_pass ;   StartNode = al_fail ),
    atom_string(GoalNode, In.job_goal),
    Algorithm = In.algorithm,
    (   Algorithm == "dfs"
    ->  find_all_dfs_paths(StartNode, GoalNode, Paths)
    ;   Algorithm == "bfs"
    ->  find_the_bfs_path(StartNode, GoalNode, Paths)
    ;   Algorithm == "a_star"
    ->  find_the_a_star_path(StartNode, GoalNode, Paths)
    ),
    reply_json_dict(Paths).


%--- Search Algorithms and Path Finding for GUI ---

find_all_dfs_paths(StartNode, GoalNode, Dict) :-
    findall(
        json{path:DescriptionPath, time:TotalTime},
        (   dfs(StartNode, GoalNode, PathNodes, TotalTime),
            path_nodes_to_description(PathNodes, DescriptionPath)
        ),
        Paths
    ),
    Dict = json{results: Paths}.

find_the_bfs_path(StartNode, GoalNode, Dict) :-
    (   find_bfs(StartNode, GoalNode, PathNodes)
    ->  path_nodes_to_description(PathNodes, DescriptionPath),
        Dict = json{results: [json{path:DescriptionPath, steps: PathNodes}]}
    ;   Dict = json{results: []}
    ).

find_the_a_star_path(StartNode, GoalNode, Dict) :-
    (   a_star(StartNode, GoalNode, PathNodes, TotalTime)
    ->  path_nodes_to_description(PathNodes, DescriptionPath),
        Dict = json{results: [json{path:DescriptionPath, time:TotalTime, steps: PathNodes}]}
    ;   Dict = json{results: []}
    ).

path_nodes_to_description([], []).
path_nodes_to_description([_], []) :- !.
path_nodes_to_description([Node1, Node2 | RestNodes], [Step | RestSteps]) :-
    path(Node1, Node2, Desc, Time),
    % Format with time for GUI display.
    format(string(Step), '~w (~d months)', [Desc, Time]),
    path_nodes_to_description([Node2 | RestNodes], RestSteps).