import std.stdio;
import std.algorithm;
import std.string;
import std.range;
import std.array;
import std.getopt;
import std.csv;
import std.file;
import std.typecons;

import prebo;

void generate()
{
    auto f = readText("./news.csv");

    Card[] news = [];
    foreach( line; csvReader!(Tuple!(string,string,string,string,string))(f) ) {

        if ( line == tuple("","","","","") ) { continue; }

        Element[] elements = [];
        foreach( elem; line[1].split('/') ) {
            elements ~= cast(Element)(elem);
        }

        news ~= Card(
            line[0],
            elements,
            cast(Category)line[2],
            cast(Rank)line[3],
            line[4]
        );
    }

    Box box = Box();
    box.reload;
    box.addNews( news );
    box.save;
}

void search(string[] args)
{
    arraySep = ",";

    string[] names = [];
    string[] elements = [];
    string[] categories = [];
    string[] ranks = [];
    bool sort_flag = false;
    bool aggregate_flag = false;
    getopt( args,
        "name", &names,
        "element", &elements,
        "category", &categories,
        "rank", &ranks,
        "sort", &sort_flag,
        "aggregate", &aggregate_flag
    );

    Box box = Box();
    box.reload;
    auto searched =
        Query( box )
            .search( QueryKey.Name, names )
            .search( QueryKey.Element, elements )
            .search( QueryKey.Category, categories )
            .search( QueryKey.Rank, ranks );

    if ( !sort_flag && !aggregate_flag ) {
        foreach( page; searched )
            writeln( page );
        return;
    }

    string format_str = "";
    Query.FinishResult[] result = [];

    if ( aggregate_flag ) {
        format_str = "count: %4d, card: %s";
        result = searched.aggregate();
    } else {
        format_str = "page: %4d, card: %s";
        result = searched.sort();
    }

    foreach ( card; result ) {
        writefln( format_str, card[0], card[1] );
    }
}

void main( string[] args )
{
    if ( args.length < 2 ) {
        writeln("Insufficient arguments.");
        return;
    }

    string command = args[1];
    switch (command) {
        case Command.Generate: {
           generate();
        } break;

        case Command.Search: {
            search(args);
        } break;

        default: {
            writeln("Usage: ./colosort {generate|search}");
        } break;
    }

}
