module prebo;

import std.stdio;
import std.json;
import std.algorithm;
import std.string;
import std.conv;
import std.file;
import std.range;
import std.array;
import std.getopt;
import std.typecons;
import std.csv;
import std.regex;
import std.uuid;

enum Command: string {
    Generate = "generate",
    Search = "search"
}

enum Element: string {
    Fire = "fire",
    Water = "water",
    Thunder = "thunder",
    None = "none"
}

enum Category: string {
    Spirit = "spirit",
    Material = "material",
    Item = "item",
    Mana = "mana",
    Ether = "ether",
    Mate = "mate",
    Crystal = "crystal",
    Gold = "gold"
}

enum Rank: string {
    CP = "C+",
    B = "B",
    BP = "B+",
    A = "A",
    AP = "A+",
    S = "S",
    SP = "S+",
    SS = "SS",
    SSP = "SS+",
    L = "L",
    None = "N"
}

struct Card
{
    UUID uuid;
    string name;
    Element[] elements;
    Category category;
    Rank rank;
    string option;

    this( string name, Element[] elements, Category category, Rank rank, string option = "" )
    {
        this.uuid = randomUUID();
        this.name = name;
        this.elements = elements;
        this.category = category;
        this.rank = rank;
        this.option = option;
    }

    this( JSONValue json )
    {
        if (json["uuid"].str.empty) {
            this.uuid = randomUUID();
        } else {
            this.uuid = UUID(json["uuid"].str);
        }

        this.name = json["name"].str;

        Element[] elements = [];
        foreach( elem; json["element"].str.split('/') ) {
            elements ~= cast(Element)elem;
        }
        this.elements = elements;
        this.category = cast(Category)(json["category"].str);
        this.rank = cast(Rank)(json["rank"].str);
        this.option =json["option"].str;
    }

    JSONValue toJson() const
    {
        string elements = "";
        foreach( elem; this.elements ) {
            elements ~= elem;
        }
        elements = elements[0..$-1];

        return JSONValue( [
            "uuid": this.uuid.toString,
            "name": this.name,
            "element": this.elements.join("/"),
            "category": this.category,
            "rank": this.rank,
            "option": this.option
        ] );
    }

    string toString() const
    {
        return "Card( name: %s, element: %s, category: %s, rank: %s, option: %s )"
               .format( name, elements.join("/"), cast(string)category, cast(string)rank, option );
    }
}

struct Page
{
    immutable uint index;
    const(Card)[] cards;
    alias cards this;

    string toString()
    {
        string[] result = [ "Page: %4d".format(index) ];
        foreach( card; cards ) {
            result ~= "     %s".format(card.toString);
        }
        return result.join("\n");
    }
}

struct Box
{
    Card[] cards;

    void reload()
    {
        cards = [];
        auto f = readText("./list.json");
        auto json = parseJSON(f);

        foreach( page; json["pages"].array ) {
            foreach( card; page["cards"].array ) {
                cards ~= Card( card );
            }
        }
    }

    void addNews( Card[] news )
    {
        cards = news ~ cards;
    }

    int opApply( int delegate( const( Page ) ) dg ) const
    {
        int result = 0;
        auto chunked = cards.chunks(10).array;

        uint index = 1;
        foreach( cards; chunked ) {
            result = dg( Page( index, cards ) );
            if (result) break;
            index++;
        }
        return result;
    }

    void deleteUUIDs( UUID[] uuids )
    {
        Card[] tmp;
        foreach( card; cards )
        {
            if (find(uuids, card.uuid).empty)
                tmp ~= card;
        }
        cards = tmp;
    }

    void save( string dir = "./")
    {
        JSONValue[] pages = [];
        foreach( page; this )
        {
            JSONValue[string] json;
            json["page"] = page.index;
            json["cards"] = page.map!"a.toJson".array;
            pages ~= JSONValue( json );
        }

        auto root = JSONValue( [ "pages": pages ] );

        string backup_path = dir ~ "backup.json";
        string list_path = dir ~ "list.json";
        if ( exists(backup_path) )
            std.file.remove(backup_path);
        if ( exists(list_path) )
            std.file.rename(list_path, backup_path);
        std.file.write(list_path, root.toPrettyString);
    }
}

enum QueryKey
{
    Name, Element, Category, Rank
}

struct Query
{
    Page[] pages;
    alias pages this;

    this( Page[] pages )
    {
        this.pages = pages;
    }

    this( Box box )
    {
        foreach( page; box ) {
            this.pages ~= page;
        }
    }

    Query search( QueryKey key, string[] values )
    {
        if (values.empty) {
            return this;
        }

        Page[] result = [];
        foreach( page; pages )
        {
            Page new_page = Page( page.index, [] );
            foreach( card; page )
            {
                final switch (key)
                {
                    case QueryKey.Name:
                    {
                        bool found = false;
                        foreach( name; values ) {
                            if ( match( card.name, regex(name) ) ) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) continue;
                    } break;

                    case QueryKey.Element:
                    {
                        bool found = false;
                        foreach( element; card.elements )
                        {
                            if (!find(values, element).empty) {
                                found = true;
                                break;
                            }
                        }
                        if (!found) continue;
                    } break;

                    case QueryKey.Category:
                    {
                        if (find(values, card.category).empty) {
                            continue;
                        }
                    } break;

                    case QueryKey.Rank:
                    {
                        if (find(values, card.rank).empty) {
                            continue;
                        }

                    } break;
                }

                new_page ~= card;
            }

            if (new_page.length > 0)
                result ~= new_page;
        }
        return Query(result);
    }

    alias Tuple!(ulong, const(Card)) FinishResult;
    private enum FinishKey { Sort, Aggregate }
    private auto finish( FinishKey FK )()
    {
        FinishResult[][string][string][string][string][string] temp;
        foreach( page; pages ) {
            foreach( card; page ) {
                temp[card.elements[0]][card.category][card.name][card.rank][card.option] ~= FinishResult( page.index, card );
            }
        }

        FinishResult[] result;

        foreach( key1; temp.keys ) {
            auto value1 = temp[key1];
            foreach( key2; value1.keys ) {
                auto value2 = value1[key2];
                foreach( key3; value2.keys ) {
                    auto value3 = value2[key3];
                    foreach( key4; value3.keys ) {
                        auto value4 = value3[key4];
                        foreach( key5; value4.keys ) {
                            auto value5 = value4[key5];

                            static if ( FK == FinishKey.Sort )
                                result ~= value5;
                            else static if ( FK == FinishKey.Aggregate )
                                result ~= FinishResult( value5.length, value5[0][1] );
                        }
                    }
                }
            }
        }

        return result;
    }

    auto sort()
    {
        return finish!(FinishKey.Sort)();
    }

    auto aggregate()
    {
        return finish!(FinishKey.Aggregate)();
    }
}

unittest
{
    Card card1 = Card( "TEST1", [Element.Fire], Category.Spirit, Rank.None, "" );
    Card card2 = Card( "TEST2", [Element.Water], Category.Spirit, Rank.None, "" );
    Card card3 = Card( "TEST3", [Element.Thunder], Category.Spirit, Rank.None, "" );

    Box box = Box();
    box.cards ~= card1;
    box.cards ~= card2;
    box.cards ~= card3;

    foreach( index, cards; box ) {
        assert( index == 1 );
        assert( cards[0] == card1 );
        assert( cards[1] == card2 );
        assert( cards[2] == card3 );
    }
}
