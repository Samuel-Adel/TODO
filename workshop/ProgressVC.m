//
//  ProgressVC.m
//  workshop
//
//  Created by Samuel Adel on 17/04/2024.
//

#import "ProgressVC.h"
#import "Task.h"
#import "DetailsVC.h"
@interface ProgressVC ()
@property NSMutableArray<Task*> *tasksArray;
@property NSMutableArray<Task*> *allTasks;

@property NSData*archivedTasks;
@property (weak, nonatomic) IBOutlet UIButton *btnFilter;
@property NSUserDefaults *defaults;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *progressImg;
@property (nonatomic, assign) BOOL isFilterOn;


@end

@implementation ProgressVC
- (IBAction)changeFilterStatus:(id)sender {
    self.isFilterOn = !self.isFilterOn;
       [self.table reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFilterOn=NO;
}
- (void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.navigationItem.rightBarButtonItems[0] setHidden:YES];
    [self.tabBarController setTitle:@"PROGRESS"];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tasksArray = [NSMutableArray<Task *> new];
    self.allTasks = [NSMutableArray<Task *> new];
    self.defaults=[NSUserDefaults standardUserDefaults];
    self.tasksArray = [self fetchSavedTasks];
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
        printf("data is here progress screen!!\n");
        tasks = [NSMutableArray<Task *> array];
        NSData* savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"taskssKey"];
        NSSet* set = [NSSet setWithArray:@[[NSArray class], [Task class]]];
        _allTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:nil];
        for(Task*t in _allTasks){
            if ([t.status isEqualToString:@"InProgress"]) {
                [tasks addObject:t];
                }
        }
    }
    return tasks;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isFilterOn) {
        return 3;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isFilterOn) {
        switch (section) {
            case 0:
                return @"Low Priority";
            case 1:
                return @"Medium Priority";
            case 2:
                return @"High Priority";
            default:
                return @"";
        }
    } else {
        return @"";
    }
}
- (NSArray<Task *> *)tasksWithPriority:(NSString *)priority {
    NSMutableArray<Task *> *tasks = [NSMutableArray<Task *> array];
    for (Task *task in self.tasksArray) {
        if ([task.priority isEqualToString:priority]) {
            [tasks addObject:task];
        }
    }
    return tasks;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isFilterOn) {
        NSArray<Task *> *tasksInSection;
        switch (section) {
            case 0:
                tasksInSection = [self tasksWithPriority:@"Low"];
                break;
            case 1:
                tasksInSection = [self tasksWithPriority:@"Medium"];
                break;
            case 2:
                tasksInSection = [self tasksWithPriority:@"High"];
                break;
            default:
                tasksInSection = @[];
        }
        return tasksInSection.count;
    } else {
        return self.tasksArray.count;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    printf("View will disappear progress screen\n");
    [self saveTasks];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    if (self.isFilterOn) {
        NSArray<Task *> *tasksInSection;
        switch (indexPath.section) {
            case 0:
                tasksInSection = [self tasksWithPriority:@"Low"];
                break;
            case 1:
                tasksInSection = [self tasksWithPriority:@"Medium"];
                break;
            case 2:
                tasksInSection = [self tasksWithPriority:@"High"];
                break;
            default:
                tasksInSection = @[];
        }
        
        Task *task = tasksInSection[indexPath.row];
        UILabel*titleText=(UILabel*)[cell.contentView viewWithTag:1];
        UILabel*descText=(UILabel*)[cell.contentView viewWithTag:2];
        UILabel*dateText=(UILabel*)[cell.contentView viewWithTag:4];
        UIImageView*image=(UIImageView*)[cell.contentView viewWithTag:3];
        titleText.text=task.name;
        descText.text=task.desc;
        dateText.text=task.date;
        image.image=[self showCellImage:task.priority];
    } else {
        Task *task = self.tasksArray[indexPath.row];
        UILabel*titleText=(UILabel*)[cell.contentView viewWithTag:1];
        UILabel*descText=(UILabel*)[cell.contentView viewWithTag:2];
        UILabel*dateText=(UILabel*)[cell.contentView viewWithTag:4];
        UIImageView*image=(UIImageView*)[cell.contentView viewWithTag:3];
        titleText.text=task.name;
        descText.text=task.desc;
        dateText.text=task.date;
        image.image=[self showCellImage:task.priority];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (void)updateTableViewVisibility {
    if (self.tasksArray.count > 0) {
        self.table.hidden = NO;
        self.progressImg.hidden=YES;
    } else {
        self.table.hidden = YES;
        self.progressImg.hidden=NO;

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

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteTaskAtIndex:indexPath.row];
    }];
    [alertController addAction:deleteAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteTaskAtIndex:(NSInteger)index {
    Task *taskToDelete = [self.tasksArray objectAtIndex:index];
    NSUInteger indexToDelete = [self.allTasks indexOfObject:taskToDelete];
    printf("Task to delete index = %d",index);
    [self.allTasks removeObjectAtIndex:indexToDelete];
    [self.tasksArray removeObjectAtIndex:index];
    [self.table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self saveTasks];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
