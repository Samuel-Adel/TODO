//
//  ToDoVC.m
//  workshop
//
//  Created by Samuel Adel on 17/04/2024.
//

#import "ToDoVC.h"
#import "Task.h"
#import "DetailsVC.h"
#import "CustomTableViewCell.h"

@interface ToDoVC ()
@property (weak, nonatomic) IBOutlet UIImageView *todoImg;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property NSMutableArray<Task*> *tasksArray;
@property NSMutableArray<Task*> *searchTasksArray;
@property NSMutableArray<Task*> *allTasks;
@property NSData*archivedTasks;
@property NSUserDefaults *defaults;

@end

@implementation ToDoVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
   

}
- (void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.navigationItem.rightBarButtonItems[0] setHidden:NO];
    [self.tabBarController setTitle:@"TODO"];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tasksArray = [NSMutableArray<Task *> new];
    self.searchTasksArray = [NSMutableArray<Task *> new];
    self.allTasks = [NSMutableArray<Task *> new];
    self.defaults=[NSUserDefaults standardUserDefaults];
    self.tasksArray = [self fetchSavedTasks];
    self.searchTasksArray=[self.tasksArray mutableCopy];
    [self.table reloadData];
    [self updateTableViewVisibility];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.tasksArray = [self.searchTasksArray mutableCopy];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        self.tasksArray = [[self.searchTasksArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    
    [self.table reloadData];
    [self updateTableViewVisibility];
}
- (nonnull NSMutableArray *)fetchSavedTasks {
    NSData* savedTasks = [_defaults objectForKey:@"taskssKey"];
    
    NSMutableArray<Task *> *tasks;
    
    if (savedTasks == nil) {
        tasks = [NSMutableArray<Task *> array];
        _allTasks = [NSMutableArray<Task *> array];
    } else {
        printf("data is here TODO Screen!!\n");
        tasks = [NSMutableArray<Task *> array];
        NSData* savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"taskssKey"];
        NSSet* set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
        _allTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:nil];
        for(Task*t in _allTasks){
            if ([t.status isEqualToString:@"Pending"]) {
                [tasks addObject:t];
                }
        }
    }
    return tasks;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasksArray.count;
}
- (void)viewWillDisappear:(BOOL)animated{
    [self saveTasks];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    Task *task = self.tasksArray[indexPath.row];
    UILabel*titleText=(UILabel*)[cell.contentView viewWithTag:1];
    UILabel*descText=(UILabel*)[cell.contentView viewWithTag:2];
    UILabel*dateText=(UILabel*)[cell.contentView viewWithTag:4];
    UIImageView*image=(UIImageView*)[cell.contentView viewWithTag:3];
    titleText.text=task.name;
    descText.text=task.desc;
    dateText.text=task.date;
    image.image=[self showCellImage:task.priority];
    
    return cell;
}
- (void)updateTableViewVisibility {
    if (self.tasksArray.count > 0) {
        self.table.hidden = NO;
        self.todoImg.hidden=YES;
    } else {
        self.table.hidden = YES;
        self.todoImg.hidden=NO;

    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAlertForDeleteConfirmationAtIndexPath:indexPath];
    }
}

- (void)showAlertForDeleteConfirmationAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Item" message:@"Are you sure you want to delete this item?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        
        [self deleteItemAtIndex:indexPath.row];
    }];
    [alertController addAction:deleteAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteItemAtIndex:(NSInteger)index {
    Task *taskToDelete = [self.tasksArray objectAtIndex:index];
    [self.allTasks removeObject:taskToDelete];
    [self.searchTasksArray removeObject:taskToDelete];
    [self.tasksArray removeObjectAtIndex:index];
    [self.table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self updateTableViewVisibility];
}


- (void) saveTasks{
    NSError*error;
    _archivedTasks=[NSKeyedArchiver archivedDataWithRootObject:_allTasks requiringSecureCoding:YES error:&error];
    [_defaults setObject:_archivedTasks forKey:@"taskssKey"];
}
- (UIImage *)showCellImage:(NSString *)priority {
    if ([priority isEqualToString:@"Low"]) {
        return [UIImage imageNamed:@"low"];
    } else if ([priority isEqualToString:@"Medium"]) {
        return [UIImage imageNamed:@"mid"];
    } else if ([priority isEqualToString:@"High"]) {
        return [UIImage imageNamed:@"high"];
    }
        return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailsVC *detailsVC =[self.storyboard instantiateViewControllerWithIdentifier:@"detailsScreenID"];
    detailsVC.task=[self.tasksArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailsVC animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
