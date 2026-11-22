# Initialize-ThreadJobBag

*Creates a bounded bag containing the supplied thread jobs.*

## DESCRIPTION

Prepares an unordered bag for the scheduler. Its capacity equals the
number of jobs supplied. The original array and the bag refer to the
same job instances, so the array retains each job after the scheduler
takes it from the bag.

## PARAMETERS

### -ThreadJob

One or more caller-created ThreadJob objects awaiting their first start.
Supply the whole array to -ThreadJob. An empty array raises an error.

## EXAMPLES

### Example 1

```powershell
$bag = Initialize-ThreadJobBag -ThreadJob $threadJobs
$bag.ConcurrentBag.BoundedCapacity
```

Returns the number of supplied jobs. Start-ThreadJobPool sets concurrency
when the bag is passed through Initialize-Pool.

## INPUTS

Supply jobs by parameter.

## OUTPUTS

A PSCustomObject containing the original ThreadJob array and the
populated ConcurrentBag wrapped in a bounded BlockingCollection.

