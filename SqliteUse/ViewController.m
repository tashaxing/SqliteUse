//
//  ViewController.m
//  SqliteUse
//
//  Created by yxhe on 16/10/25.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

// ---- sqlite的简单使用 ---- //

#import <sqlite3.h>
#import "ViewController.h"

@interface ViewController ()
{
    sqlite3 *sqliteDB;
}
@end

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    sqliteDB = nil;
    // initialize
    [self createDataBaseTable];
}

- (const char *)sqlPath
{
    // get db path
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [dirPath stringByAppendingPathComponent:@"test.db"];
    
    // create the db file if not exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        [[NSFileManager defaultManager] createFileAtPath:dbPath contents:nil attributes:nil];
    }
    
    const char *dbPathStr = dbPath.UTF8String;
    return dbPathStr;
}

- (void)createDataBaseTable
{
    // create/open db
    int result = sqlite3_open([self sqlPath], &sqliteDB);
    if (result == SQLITE_OK)
    {
        NSLog(@"create database success");
    }
    else
    {
        NSLog(@"failed to create database %d", result);
    }
    
    // create table
    char *error = NULL;
    const char *createQuery = "create table if not exists Person(id integer primary key autoincrement, name char, age integer)";
    result = sqlite3_exec(sqliteDB, createQuery, NULL, NULL, &error);
    if (result == SQLITE_OK)
    {
        NSLog(@"create table success");
    }
    else
    {
        NSLog(@"failed to create table %s", error);
    }
}

#pragma mark - Sql operation
// open db
- (IBAction)openDB:(id)sender
{
    int result = sqlite3_open([self sqlPath], &sqliteDB);
    if (result == SQLITE_OK)
    {
        NSLog(@"create database success");
    }
    else
    {
        NSLog(@"failed to create database %d", result);
    }
}

// query db
- (IBAction)selectDB:(id)sender
{
    sqlite3_stmt *stmt = NULL;
    const char *selectQuery = "select * from Person";
    int result = sqlite3_prepare_v2(sqliteDB, selectQuery, -1, &stmt, NULL);
    if (result == SQLITE_OK)
    {
        self.textView.text = @"";
        // line by line until the end
        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            int idNum = sqlite3_column_int(stmt, 0);
            char *name = (char *)sqlite3_column_text(stmt, 1);
            int age = sqlite3_column_int(stmt, 2);
            
            self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%d, %@, %d\n", idNum, [NSString stringWithUTF8String:name], age]];
            
        }
    }
    else
    {
        NSLog(@"select failed %d", result);
    }
    
    // release resource
    sqlite3_finalize(stmt);
}

// add record
- (IBAction)addRecord:(id)sender
{
    sqlite3_stmt *stmt = NULL;
    srand((unsigned int)time(0));
    int randomNum = 15 + rand() % 10;
    NSString *sqlStr = [NSString stringWithFormat:@"insert into Person(name, age) values('Ethan', %d)", randomNum];
    const char *insertQuery = sqlStr.UTF8String;
    int result = sqlite3_prepare_v2(sqliteDB, insertQuery, -1, &stmt, NULL);
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    else
    {
        NSLog(@"insert failed %d", result);
    }
    
    // release resource
    sqlite3_finalize(stmt);
}

// modify record
- (IBAction)modifyDB:(id)sender
{
    sqlite3_stmt *stmt = NULL;
    srand((unsigned int)time(0));
    int randomNum = 15 + rand() % 10;
    NSString *sqlStr = [NSString stringWithFormat:@"update Person set age = %d where name = 'Ethan'", randomNum];
    const char *modifyQuery = sqlStr.UTF8String;
    int result = sqlite3_prepare_v2(sqliteDB, modifyQuery, -1, &stmt, NULL);
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    else
    {
        NSLog(@"modify failed %d", result);
    }
    
    // release resource
    sqlite3_finalize(stmt);
}

// delete record
- (IBAction)deleteRecord:(id)sender
{
    sqlite3_stmt *stmt = NULL;
    const char *modifyQuery = "delete from Person where name = 'Ethan'";
    int result = sqlite3_prepare_v2(sqliteDB, modifyQuery, -1, &stmt, NULL);
    if (result == SQLITE_OK)
    {
        sqlite3_step(stmt);
    }
    else
    {
        NSLog(@"modify failed %d", result);
    }
    
    // release resource
    sqlite3_finalize(stmt);
}

// close db
- (IBAction)closeDB:(id)sender
{
    sqlite3_close(sqliteDB);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
