//-------------------------------------------------------------------------------------------------------
// Copyright (C) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt file in the project root for full license information.
//-------------------------------------------------------------------------------------------------------
#include "RuntimeLibraryPch.h"

namespace Js
{
	JavascriptPromise::JavascriptPromise(DynamicType * type)
		: DynamicObject(type)
	{
		Assert(type->GetTypeId() == TypeIds_Promise);

		this->status = PromiseStatusCode_Undefined;
		this->result = nullptr;
		this->resolveReactions = nullptr;
		this->rejectReactions = nullptr;
	}

	// Promise() as defined by ES 2016 Sections 25.4.3.1
	Var JavascriptPromise::NewInstance(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		AssertMsg(args.Info.Count > 0, "Should always have implicit 'this'");

		ScriptContext* scriptContext = function->GetScriptContext();
		JavascriptLibrary* library = scriptContext->GetLibrary();

		CHAKRATEL_LANGSTATS_INC_BUILTINCOUNT(PromiseCount);

		// SkipDefaultNewObject function flag should have prevented the default object from
		// being created, except when call true a host dispatch
		Var newTarget = callInfo.Flags & CallFlags_NewTarget ? args.Values[args.Info.Count] : args[0];
		bool isCtorSuperCall = (callInfo.Flags & CallFlags_New) && newTarget != nullptr && !JavascriptOperators::IsUndefined(newTarget);
		Assert(isCtorSuperCall || !(callInfo.Flags & CallFlags_New) || args[0] == nullptr
			|| JavascriptOperators::GetTypeId(args[0]) == TypeIds_HostDispatch);

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise"));

		// 1. If NewTarget is undefined, throw a TypeError exception.
		if ((callInfo.Flags & CallFlags_New) != CallFlags_New || (newTarget != nullptr && JavascriptOperators::IsUndefined(newTarget)))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_ClassConstructorCannotBeCalledWithoutNew, _u("Promise"));
		}

		// 2. If IsCallable(executor) is false, throw a TypeError exception.
		if (args.Info.Count < 2 || !JavascriptConversion::IsCallable(args[1]))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_FunctionArgument_NeedFunction, _u("Promise"));
		}
		RecyclableObject* executor = RecyclableObject::FromVar(args[1]);

		// 3. Let promise be ? OrdinaryCreateFromConstructor(NewTarget, "%PromisePrototype%", «[[PromiseState]], [[PromiseResult]], [[PromiseFulfillReactions]], [[PromiseRejectReactions]], [[PromiseIsHandled]] ?.
		JavascriptPromise* promise = library->CreatePromise();
		if (isCtorSuperCall)
		{
			JavascriptOperators::OrdinaryCreateFromConstructor(RecyclableObject::FromVar(newTarget), promise, library->GetPromisePrototype(), scriptContext);
		}

		JavascriptPromiseResolveOrRejectFunction* resolve;
		JavascriptPromiseResolveOrRejectFunction* reject;

		// 4. Set promise's [[PromiseState]] internal slot to "pending".
		// 5. Set promise's [[PromiseFulfillReactions]] internal slot to a new empty List.
		// 6. Set promise's [[PromiseRejectReactions]] internal slot to a new empty List.
		// 7. Set promise's [[PromiseIsHandled]] internal slot to false.
		// 8. Let resolvingFunctions be CreateResolvingFunctions(promise).
		InitializePromise(promise, &resolve, &reject, scriptContext);

		JavascriptExceptionObject* exception = nullptr;

		// 9. Let completion be Call(executor, undefined, ?resolvingFunctions.[[Resolve]], resolvingFunctions.[[Reject]] ?.
		try
		{
			executor->GetEntryPoint()(executor, CallInfo(CallFlags_Value, 3),
				library->GetUndefined(),
				resolve,
				reject);
		}
		catch (JavascriptExceptionObject* e)
		{
			exception = e;
		}

		if (exception != nullptr)
		{
			// 10. If completion is an abrupt completion, then
			//    a. Perform ? Call(resolvingFunctions.[[Reject]], undefined, ?completion.[[Value]] ?.
			TryRejectWithExceptionObject(exception, reject, scriptContext);
		}

		// 11. Return promise. 
		return promise;
	}

	void JavascriptPromise::InitializePromise(JavascriptPromise* promise, JavascriptPromiseResolveOrRejectFunction** resolve, JavascriptPromiseResolveOrRejectFunction** reject, ScriptContext* scriptContext)
	{
		Assert(promise->status == PromiseStatusCode_Undefined);
		Assert(resolve);
		Assert(reject);

		Recycler* recycler = scriptContext->GetRecycler();
		JavascriptLibrary* library = scriptContext->GetLibrary();

		promise->status = PromiseStatusCode_Unresolved;

		promise->resolveReactions = RecyclerNew(recycler, JavascriptPromiseReactionList, recycler);
		promise->rejectReactions = RecyclerNew(recycler, JavascriptPromiseReactionList, recycler);

		JavascriptPromiseResolveOrRejectFunctionAlreadyResolvedWrapper* alreadyResolvedRecord = RecyclerNewStructZ(scriptContext->GetRecycler(), JavascriptPromiseResolveOrRejectFunctionAlreadyResolvedWrapper);
		alreadyResolvedRecord->alreadyResolved = false;

		*resolve = library->CreatePromiseResolveOrRejectFunction(EntryResolveOrRejectFunction, promise, false, alreadyResolvedRecord);
		*reject = library->CreatePromiseResolveOrRejectFunction(EntryResolveOrRejectFunction, promise, true, alreadyResolvedRecord);
	}

	bool JavascriptPromise::Is(Var aValue)
	{
		return Js::JavascriptOperators::GetTypeId(aValue) == TypeIds_Promise;
	}

	JavascriptPromise* JavascriptPromise::FromVar(Js::Var aValue)
	{
		AssertMsg(Is(aValue), "Ensure var is actually a 'JavascriptPromise'");

		return static_cast<JavascriptPromise *>(RecyclableObject::FromVar(aValue));
	}

	BOOL JavascriptPromise::GetDiagValueString(StringBuilder<ArenaAllocator>* stringBuilder, ScriptContext* requestContext)
	{
		stringBuilder->AppendCppLiteral(_u("[...]"));

		return TRUE;
	}

	BOOL JavascriptPromise::GetDiagTypeString(StringBuilder<ArenaAllocator>* stringBuilder, ScriptContext* requestContext)
	{
		stringBuilder->AppendCppLiteral(_u("Promise"));
		return TRUE;
	}

	JavascriptPromiseReactionList* JavascriptPromise::GetResolveReactions()
	{
		return this->resolveReactions;
	}

	JavascriptPromiseReactionList* JavascriptPromise::GetRejectReactions()
	{
		return this->rejectReactions;
	}

	// Promise.all as described in ES 2015 Section 25.4.4.1
	Var JavascriptPromise::EntryAll(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise.all"));

		// 1. Let C be the this value.
		Var constructor = args[0];

		// 2. If Type(C) is not Object, throw a TypeError exception.
		if (!JavascriptOperators::IsObject(constructor))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_This_NeedObject, _u("Promise.all"));
		}

		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var iterable;

		if (args.Info.Count > 1)
		{
			iterable = args[1];
		}
		else
		{
			iterable = library->GetUndefined();
		}

		// 3. Let promiseCapability be NewPromiseCapability(C).
		JavascriptPromiseCapability* promiseCapability = NewPromiseCapability(constructor, scriptContext);

		// We know that constructor is an object at this point - further, we even know that it is a constructor - because NewPromiseCapability
		// would throw otherwise. That means we can safely cast constructor into a RecyclableObject* now and avoid having to perform ToObject
		// as part of the Invoke operation performed inside the loop below.
		RecyclableObject* constructorObject = RecyclableObject::FromVar(constructor);

		uint32 index = 0;
		JavascriptArray* values = nullptr;

		// We can't use a simple counter for the remaining element count since each Promise.all Resolve Element Function needs to know how many
		// elements are remaining when it runs and needs to update that counter for all other functions created by this call to Promise.all.
		// We can't just use a static variable, either, since this element count is only used for the Promise.all Resolve Element Functions created
		// by this call to Promise.all.
		JavascriptPromiseAllResolveElementFunctionRemainingElementsWrapper* remainingElementsWrapper = RecyclerNewStructZ(scriptContext->GetRecycler(), JavascriptPromiseAllResolveElementFunctionRemainingElementsWrapper);
		remainingElementsWrapper->remainingElements = 1;

		JavascriptExceptionObject* exception = nullptr;

		try
		{
			// 4. Let iterator be GetIterator(iterable).
			RecyclableObject* iterator = JavascriptOperators::GetIterator(iterable, scriptContext);
			Var next;
			values = library->CreateArray(0);

			while (JavascriptOperators::IteratorStepAndValue(iterator, scriptContext, &next))
			{
				Var resolveVar = JavascriptOperators::GetProperty(constructorObject, Js::PropertyIds::resolve, scriptContext);

				if (!JavascriptConversion::IsCallable(resolveVar))
				{
					JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction);
				}

				RecyclableObject* resolveFunc = RecyclableObject::FromVar(resolveVar);

				Var nextPromise = resolveFunc->GetEntryPoint()(resolveFunc, Js::CallInfo(CallFlags_Value, 2),
					constructorObject,
					next);

				JavascriptPromiseAllResolveElementFunction* resolveElement = library->CreatePromiseAllResolveElementFunction(EntryAllResolveElementFunction, index, values, promiseCapability, remainingElementsWrapper);

				remainingElementsWrapper->remainingElements++;

				RecyclableObject* nextPromiseObject;

				if (!JavascriptConversion::ToObject(nextPromise, scriptContext, &nextPromiseObject))
				{
					JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedObject);
				}

				Var thenVar = JavascriptOperators::GetProperty(nextPromiseObject, Js::PropertyIds::then, scriptContext);

				if (!JavascriptConversion::IsCallable(thenVar))
				{
					JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction);
				}

				RecyclableObject* thenFunc = RecyclableObject::FromVar(thenVar);

				thenFunc->GetEntryPoint()(thenFunc, Js::CallInfo(CallFlags_Value, 3),
					nextPromiseObject,
					resolveElement,
					promiseCapability->GetReject());

				index++;
			}
		}
		catch (JavascriptExceptionObject* e)
		{
			exception = e;
		}

		if (exception != nullptr)
		{
			TryRejectWithExceptionObject(exception, promiseCapability->GetReject(), scriptContext);

			// We need to explicitly return here to make sure we don't resolve in case index == 0 here.
			// That would happen if GetIterator or IteratorValue throws an exception in the first iteration.
			return promiseCapability->GetPromise();
		}

		remainingElementsWrapper->remainingElements--;

		// We want this call to happen outside the try statement because if it throws, we aren't supposed to reject the promise.
		if (remainingElementsWrapper->remainingElements == 0)
		{
			Assert(values != nullptr);

			TryCallResolveOrRejectHandler(promiseCapability->GetResolve(), values, scriptContext);
		}

		return promiseCapability->GetPromise();
	}

	// Promise.prototype.catch as defined in ES 2015 Section 25.4.5.1
	Var JavascriptPromise::EntryCatch(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise.prototype.catch"));

		RecyclableObject* promise;

		if (!JavascriptConversion::ToObject(args[0], scriptContext, &promise))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_This_NeedObject, _u("Promise.prototype.catch"));
		}

		Var funcVar = JavascriptOperators::GetProperty(promise, Js::PropertyIds::then, scriptContext);

		if (!JavascriptConversion::IsCallable(funcVar))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_FunctionArgument_NeedFunction, _u("Promise.prototype.catch"));
		}

		Var onRejected;
		RecyclableObject* undefinedVar = scriptContext->GetLibrary()->GetUndefined();

		if (args.Info.Count > 1)
		{
			onRejected = args[1];
		}
		else
		{
			onRejected = undefinedVar;
		}

		RecyclableObject* func = RecyclableObject::FromVar(funcVar);

		return func->GetEntryPoint()(func, Js::CallInfo(CallFlags_Value, 3),
			promise,
			undefinedVar,
			onRejected);
	}

	// Promise.race as described in ES 2015 Section 25.4.4.3
	Var JavascriptPromise::EntryRace(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise.race"));

		// 1. Let C be the this value.
		Var constructor = args[0];

		// 2. If Type(C) is not Object, throw a TypeError exception.
		if (!JavascriptOperators::IsObject(constructor))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_This_NeedObject, _u("Promise.race"));
		}

		Var undefinedVar = scriptContext->GetLibrary()->GetUndefined();
		Var iterable;

		if (args.Info.Count > 1)
		{
			iterable = args[1];
		}
		else
		{
			iterable = undefinedVar;
		}

		// 3. Let promiseCapability be NewPromiseCapability(C).
		JavascriptPromiseCapability* promiseCapability = NewPromiseCapability(constructor, scriptContext);

		// We know that constructor is an object at this point - further, we even know that it is a constructor - because NewPromiseCapability
		// would throw otherwise. That means we can safely cast constructor into a RecyclableObject* now and avoid having to perform ToObject
		// as part of the Invoke operation performed inside the loop below.
		RecyclableObject* constructorObject = RecyclableObject::FromVar(constructor);
		JavascriptExceptionObject* exception = nullptr;

		try
		{
			// 4. Let iterator be GetIterator(iterable).
			RecyclableObject* iterator = JavascriptOperators::GetIterator(iterable, scriptContext);
			Var next;

			while (JavascriptOperators::IteratorStepAndValue(iterator, scriptContext, &next))
			{
				Var resolveVar = JavascriptOperators::GetProperty(constructorObject, Js::PropertyIds::resolve, scriptContext);

				if (!JavascriptConversion::IsCallable(resolveVar))
				{
					JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction);
				}

				RecyclableObject* resolveFunc = RecyclableObject::FromVar(resolveVar);

				Var nextPromise = resolveFunc->GetEntryPoint()(resolveFunc, Js::CallInfo(CallFlags_Value, 2),
					constructorObject,
					next);

				RecyclableObject* nextPromiseObject;

				if (!JavascriptConversion::ToObject(nextPromise, scriptContext, &nextPromiseObject))
				{
					JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedObject);
				}

				Var thenVar = JavascriptOperators::GetProperty(nextPromiseObject, Js::PropertyIds::then, scriptContext);

				if (!JavascriptConversion::IsCallable(thenVar))
				{
					JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction);
				}

				RecyclableObject* thenFunc = RecyclableObject::FromVar(thenVar);

				thenFunc->GetEntryPoint()(thenFunc, Js::CallInfo(CallFlags_Value, 3),
					nextPromiseObject,
					promiseCapability->GetResolve(),
					promiseCapability->GetReject());
			}
		}
		catch (JavascriptExceptionObject* e)
		{
			exception = e;
		}

		if (exception != nullptr)
		{
			TryRejectWithExceptionObject(exception, promiseCapability->GetReject(), scriptContext);
		}

		return promiseCapability->GetPromise();
	}

	// Promise.reject as described in ES 2015 Section 25.4.4.4
	Var JavascriptPromise::EntryReject(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise.reject"));

		// 1. Let C be the this value.
		Var constructor = args[0];

		// 2. If Type(C) is not Object, throw a TypeError exception.
		if (!JavascriptOperators::IsObject(constructor))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_This_NeedObject, _u("Promise.reject"));
		}

		Var r;

		if (args.Info.Count > 1)
		{
			r = args[1];
		}
		else
		{
			r = scriptContext->GetLibrary()->GetUndefined();
		}

		// 3. Let promiseCapability be NewPromiseCapability(C).
		JavascriptPromiseCapability* promiseCapability = NewPromiseCapability(constructor, scriptContext);

		// 4. Perform ? Call(promiseCapability.[[Reject]], undefined, ?r ?.
		TryCallResolveOrRejectHandler(promiseCapability->GetReject(), r, scriptContext);

		// 5. Return promiseCapability.[[Promise]].
		return promiseCapability->GetPromise();
	}

	// Promise.resolve as described in ES 2015 Section 25.4.4.5
	Var JavascriptPromise::EntryResolve(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise.resolve"));

		Var x;

		// 1. Let C be the this value.
		Var constructor = args[0];

		// 2. If Type(C) is not Object, throw a TypeError exception.
		if (!JavascriptOperators::IsObject(constructor))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_This_NeedObject, _u("Promise.resolve"));
		}

		if (args.Info.Count > 1)
		{
			x = args[1];
		}
		else
		{
			x = scriptContext->GetLibrary()->GetUndefined();
		}

		// 3. If IsPromise(x) is true,
		if (JavascriptPromise::Is(x))
		{
			// a. Let xConstructor be Get(x, "constructor").
			Var xConstructor = JavascriptOperators::GetProperty((RecyclableObject*)x, PropertyIds::constructor, scriptContext);

			// b. If SameValue(xConstructor, C) is true, return x.
			if (JavascriptConversion::SameValue(xConstructor, constructor))
			{
				return x;
			}
		}

		// 4. Let promiseCapability be NewPromiseCapability(C).
		JavascriptPromiseCapability* promiseCapability = NewPromiseCapability(constructor, scriptContext);

		// 5. Perform ? Call(promiseCapability.[[Resolve]], undefined, ?x ?.
		TryCallResolveOrRejectHandler(promiseCapability->GetResolve(), x, scriptContext);

		// 6. Return promiseCapability.[[Promise]].
		return promiseCapability->GetPromise();
	}

	// Promise.prototype.then as described in ES 2015 Section 25.4.5.3
	Var JavascriptPromise::EntryThen(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();

		AUTO_TAG_NATIVE_LIBRARY_ENTRY(function, callInfo, _u("Promise.prototype.then"));

		JavascriptPromise* promise;

		if (args.Info.Count < 1 || !JavascriptPromise::Is(args[0]))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_This_NeedPromise, _u("Promise.prototype.then"));
		}

		promise = JavascriptPromise::FromVar(args[0]);

		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var constructor = JavascriptOperators::SpeciesConstructor(promise, scriptContext->GetLibrary()->GetPromiseConstructor(), scriptContext);
		JavascriptPromiseCapability* promiseCapability = NewPromiseCapability(constructor, scriptContext);
		RecyclableObject* rejectionHandler;
		RecyclableObject* fulfillmentHandler;

		if (args.Info.Count > 1 && JavascriptConversion::IsCallable(args[1]))
		{
			fulfillmentHandler = RecyclableObject::FromVar(args[1]);
		}
		else
		{
			fulfillmentHandler = library->GetIdentityFunction();
		}

		if (args.Info.Count > 2 && JavascriptConversion::IsCallable(args[2]))
		{
			rejectionHandler = RecyclableObject::FromVar(args[2]);
		}
		else
		{
			rejectionHandler = library->GetThrowerFunction();
		}

		JavascriptPromiseReaction* resolveReaction = JavascriptPromiseReaction::New(promiseCapability, fulfillmentHandler, scriptContext);
		JavascriptPromiseReaction* rejectReaction = JavascriptPromiseReaction::New(promiseCapability, rejectionHandler, scriptContext);

		switch (promise->status)
		{
		case PromiseStatusCode_Unresolved:
			promise->resolveReactions->Add(resolveReaction);
			promise->rejectReactions->Add(rejectReaction);
			break;
		case PromiseStatusCode_HasResolution:
			EnqueuePromiseReactionTask(resolveReaction, promise->result, scriptContext);
			break;
		case PromiseStatusCode_HasRejection:
			EnqueuePromiseReactionTask(rejectReaction, promise->result, scriptContext);
			break;
		default:
			AssertMsg(false, "Promise status is in an invalid state");
			break;
		}

		return promiseCapability->GetPromise();
	}

	// Promise Reject and Resolve Functions as described in ES 2015 Section 25.4.1.4.1 and 25.4.1.4.2
	Var JavascriptPromise::EntryResolveOrRejectFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();
		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var undefinedVar = library->GetUndefined();
		Var resolution;

		if (args.Info.Count > 1)
		{
			resolution = args[1];
		}
		else
		{
			resolution = undefinedVar;
		}

		JavascriptPromiseResolveOrRejectFunction* resolveOrRejectFunction = JavascriptPromiseResolveOrRejectFunction::FromVar(function);

		if (resolveOrRejectFunction->IsAlreadyResolved())
		{
			return undefinedVar;
		}

		resolveOrRejectFunction->SetAlreadyResolved(true);

		bool rejecting = resolveOrRejectFunction->IsRejectFunction();

		JavascriptPromise* promise = resolveOrRejectFunction->GetPromise();

		// We only need to check SameValue and check for thenable resolution in the Resolve function case (not Reject)
		if (!rejecting)
		{
			if (JavascriptConversion::SameValue(resolution, promise))
			{
				JavascriptError* selfResolutionError = scriptContext->GetLibrary()->CreateTypeError();
				JavascriptError::SetErrorMessage(selfResolutionError, JSERR_PromiseSelfResolution, _u(""), scriptContext);

				resolution = selfResolutionError;
				rejecting = true;
			}
			else if (RecyclableObject::Is(resolution))
			{
				try
				{
					RecyclableObject* thenable = RecyclableObject::FromVar(resolution);
					Var then = JavascriptOperators::GetProperty(thenable, Js::PropertyIds::then, scriptContext);

					if (JavascriptConversion::IsCallable(then))
					{
						JavascriptPromiseResolveThenableTaskFunction* resolveThenableTaskFunction = library->CreatePromiseResolveThenableTaskFunction(EntryResolveThenableTaskFunction, promise, thenable, RecyclableObject::FromVar(then));

						library->EnqueueTask(resolveThenableTaskFunction);

						return undefinedVar;
					}
				}
				catch (JavascriptExceptionObject* e)
				{
					resolution = e->GetThrownObject(scriptContext);

					if (resolution == nullptr)
					{
						resolution = undefinedVar;
					}

					rejecting = true;
				}
			}
		}

		JavascriptPromiseReactionList* reactions;
		PromiseStatus newStatus;

		// Need to check rejecting state again as it might have changed due to failures
		if (rejecting)
		{
			reactions = promise->GetRejectReactions();
			newStatus = PromiseStatusCode_HasRejection;
		}
		else
		{
			reactions = promise->GetResolveReactions();
			newStatus = PromiseStatusCode_HasResolution;
		}

		Assert(resolution != nullptr);

		promise->result = resolution;
		promise->resolveReactions = nullptr;
		promise->rejectReactions = nullptr;
		promise->status = newStatus;

		return TriggerPromiseReactions(reactions, resolution, scriptContext);
	}

	// Promise Capabilities Executor Function as described in ES 2015 Section 25.4.1.6.2
	Var JavascriptPromise::EntryCapabilitiesExecutorFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();
		Var undefinedVar = scriptContext->GetLibrary()->GetUndefined();
		Var resolve = undefinedVar;
		Var reject = undefinedVar;

		if (args.Info.Count > 1)
		{
			resolve = args[1];

			if (args.Info.Count > 2)
			{
				reject = args[2];
			}
		}

		JavascriptPromiseCapabilitiesExecutorFunction* capabilitiesExecutorFunction = JavascriptPromiseCapabilitiesExecutorFunction::FromVar(function);
		JavascriptPromiseCapability* promiseCapability = capabilitiesExecutorFunction->GetCapability();

		if (!JavascriptOperators::IsUndefined(promiseCapability->GetResolve()) || !JavascriptOperators::IsUndefined(promiseCapability->GetReject()))
		{
			JavascriptError::ThrowTypeErrorVar(scriptContext, JSERR_UnexpectedMetadataFailure, _u("Promise"));
		}

		promiseCapability->SetResolve(resolve);
		promiseCapability->SetReject(reject);

		return undefinedVar;
	}

	// Promise Reaction Task Function as described in ES 2015 Section 25.4.2.1
	Var JavascriptPromise::EntryReactionTaskFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();
		Var undefinedVar = scriptContext->GetLibrary()->GetUndefined();

		JavascriptPromiseReactionTaskFunction* reactionTaskFunction = JavascriptPromiseReactionTaskFunction::FromVar(function);
		JavascriptPromiseReaction* reaction = reactionTaskFunction->GetReaction();
		Var argument = reactionTaskFunction->GetArgument();
		JavascriptPromiseCapability* promiseCapability = reaction->GetCapabilities();
		RecyclableObject* handler = reaction->GetHandler();
		Var handlerResult = nullptr;
		JavascriptExceptionObject* exception = nullptr;

		{
			Js::JavascriptExceptionOperators::AutoCatchHandlerExists autoCatchHandlerExists(scriptContext);
			try
			{
				handlerResult = handler->GetEntryPoint()(handler, Js::CallInfo(Js::CallFlags::CallFlags_Value, 2),
					undefinedVar,
					argument);
			}
			catch (JavascriptExceptionObject* e)
			{
				exception = e;
			}
		}

		if (exception != nullptr)
		{
			return TryRejectWithExceptionObject(exception, promiseCapability->GetReject(), scriptContext);
		}

		Assert(handlerResult != nullptr);

		return TryCallResolveOrRejectHandler(promiseCapability->GetResolve(), handlerResult, scriptContext);
	}

	Var JavascriptPromise::TryCallResolveOrRejectHandler(Var handler, Var value, ScriptContext* scriptContext)
	{
		Var undefinedVar = scriptContext->GetLibrary()->GetUndefined();

		if (!JavascriptConversion::IsCallable(handler))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction);
		}

		RecyclableObject* handlerFunc = RecyclableObject::FromVar(handler);

		return handlerFunc->GetEntryPoint()(handlerFunc, CallInfo(CallFlags_Value, 2),
			undefinedVar,
			value);
	}

	Var JavascriptPromise::TryRejectWithExceptionObject(JavascriptExceptionObject* exceptionObject, Var handler, ScriptContext* scriptContext)
	{
		Var thrownObject = exceptionObject->GetThrownObject(scriptContext);

		if (thrownObject == nullptr)
		{
			thrownObject = scriptContext->GetLibrary()->GetUndefined();
		}

		return TryCallResolveOrRejectHandler(handler, thrownObject, scriptContext);
	}

	// Promise Resolve Thenable Job as described in ES 2015 Section 25.4.2.2
	Var JavascriptPromise::EntryResolveThenableTaskFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();
		JavascriptLibrary* library = scriptContext->GetLibrary();

		JavascriptPromiseResolveThenableTaskFunction* resolveThenableTaskFunction = JavascriptPromiseResolveThenableTaskFunction::FromVar(function);
		JavascriptPromise* promise = resolveThenableTaskFunction->GetPromise();
		RecyclableObject* thenable = resolveThenableTaskFunction->GetThenable();
		RecyclableObject* thenFunction = resolveThenableTaskFunction->GetThenFunction();

		JavascriptPromiseResolveOrRejectFunctionAlreadyResolvedWrapper* alreadyResolvedRecord = RecyclerNewStructZ(scriptContext->GetRecycler(), JavascriptPromiseResolveOrRejectFunctionAlreadyResolvedWrapper);
		alreadyResolvedRecord->alreadyResolved = false;

		JavascriptPromiseResolveOrRejectFunction* resolve = library->CreatePromiseResolveOrRejectFunction(EntryResolveOrRejectFunction, promise, false, alreadyResolvedRecord);
		JavascriptPromiseResolveOrRejectFunction* reject = library->CreatePromiseResolveOrRejectFunction(EntryResolveOrRejectFunction, promise, true, alreadyResolvedRecord);
		JavascriptExceptionObject* exception = nullptr;

		{
			Js::JavascriptExceptionOperators::AutoCatchHandlerExists autoCatchHandlerExists(scriptContext);
			try
			{
				return thenFunction->GetEntryPoint()(thenFunction, Js::CallInfo(Js::CallFlags::CallFlags_Value, 3),
					thenable,
					resolve,
					reject);
			}
			catch (JavascriptExceptionObject* e)
			{
				exception = e;
			}
		}

		Assert(exception != nullptr);

		return TryRejectWithExceptionObject(exception, reject, scriptContext);
	}

	// Promise Identity Function as described in ES 2015Section 25.4.5.3.1
	Var JavascriptPromise::EntryIdentityFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		if (args.Info.Count > 1)
		{
			Assert(args[1] != nullptr);

			return args[1];
		}
		else
		{
			return function->GetScriptContext()->GetLibrary()->GetUndefined();
		}
	}

	// Promise Thrower Function as described in ES 2015Section 25.4.5.3.3
	Var JavascriptPromise::EntryThrowerFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();
		Var arg;

		if (args.Info.Count > 1)
		{
			Assert(args[1] != nullptr);

			arg = args[1];
		}
		else
		{
			arg = scriptContext->GetLibrary()->GetUndefined();
		}

		JavascriptExceptionOperators::Throw(arg, scriptContext);
	}

	// Promise.all Resolve Element Function as described in ES6.0 (Release Candidate 3) Section 25.4.4.1.2
	Var JavascriptPromise::EntryAllResolveElementFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);
		Assert(!(callInfo.Flags & CallFlags_New));

		ScriptContext* scriptContext = function->GetScriptContext();
		Var undefinedVar = scriptContext->GetLibrary()->GetUndefined();
		Var x;

		if (args.Info.Count > 1)
		{
			x = args[1];
		}
		else
		{
			x = undefinedVar;
		}

		JavascriptPromiseAllResolveElementFunction* allResolveElementFunction = JavascriptPromiseAllResolveElementFunction::FromVar(function);

		if (allResolveElementFunction->IsAlreadyCalled())
		{
			return undefinedVar;
		}

		allResolveElementFunction->SetAlreadyCalled(true);

		uint32 index = allResolveElementFunction->GetIndex();
		JavascriptArray* values = allResolveElementFunction->GetValues();
		JavascriptPromiseCapability* promiseCapability = allResolveElementFunction->GetCapabilities();
		JavascriptExceptionObject* exception = nullptr;

		try
		{
			values->DirectSetItemAt(index, x);
		}
		catch (JavascriptExceptionObject* e)
		{
			exception = e;
		}

		if (exception != nullptr)
		{
			return TryRejectWithExceptionObject(exception, promiseCapability->GetReject(), scriptContext);
		}

		if (allResolveElementFunction->DecrementRemainingElements() == 0)
		{
			return TryCallResolveOrRejectHandler(promiseCapability->GetResolve(), values, scriptContext);
		}

		return undefinedVar;
	}

	Var JavascriptPromise::EntryJavascriptPromiseAsyncSpawnExecutorFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);

		ScriptContext* scriptContext = function->GetScriptContext();
		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var undefinedVar = library->GetUndefined();
		Var resolve = undefinedVar;
		Var reject = undefinedVar;

		Assert(args.Info.Count == 3);

		resolve = args[1];
		reject = args[2];

		Assert(JavascriptPromiseAsyncSpawnExecutorFunction::Is(function));
		JavascriptPromiseAsyncSpawnExecutorFunction* asyncSpawnExecutorFunction = JavascriptPromiseAsyncSpawnExecutorFunction::FromVar(function);
		JavascriptGenerator* genF = asyncSpawnExecutorFunction->GetGeneratorFunction();
		Var self = asyncSpawnExecutorFunction->GetTarget();

		JavascriptGenerator* gen = JavascriptGenerator::FromVar(genF->GetEntryPoint()(genF, CallInfo(CallFlags_Value, 2), undefinedVar, self));
		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* nextFunction = library->CreatePromiseAsyncSpawnStepArgumentExecutorFunction(EntryJavascriptPromiseAsyncSpawnStepNextExecutorFunction, gen, undefinedVar);

		Assert(JavascriptFunction::Is(resolve) && JavascriptFunction::Is(reject));
		AsyncSpawnStep(nextFunction, gen, JavascriptFunction::FromVar(resolve), JavascriptFunction::FromVar(reject));

		return undefinedVar;
	}

	Var JavascriptPromise::EntryJavascriptPromiseAsyncSpawnStepNextExecutorFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);

		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* asyncSpawnStepArgumentExecutorFunction = JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::FromVar(function);
		Var argument = asyncSpawnStepArgumentExecutorFunction->GetArgument();

		JavascriptFunction* next = JavascriptFunction::FromVar(JavascriptOperators::GetProperty(asyncSpawnStepArgumentExecutorFunction->GetGenerator(), PropertyIds::next, function->GetScriptContext()));
		return next->GetEntryPoint()(next, CallInfo(CallFlags_Value, 2), asyncSpawnStepArgumentExecutorFunction->GetGenerator(), argument);
	}

	Var JavascriptPromise::EntryJavascriptPromiseAsyncSpawnStepThrowExecutorFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);

		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* asyncSpawnStepArgumentExecutorFunction = JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::FromVar(function);
		JavascriptFunction* throw_ = JavascriptFunction::FromVar(JavascriptOperators::GetProperty(asyncSpawnStepArgumentExecutorFunction->GetGenerator(), PropertyIds::throw_, function->GetScriptContext()));
		return throw_->GetEntryPoint()(throw_, CallInfo(CallFlags_Value, 2), asyncSpawnStepArgumentExecutorFunction->GetGenerator(), asyncSpawnStepArgumentExecutorFunction->GetArgument());
	}

	Var JavascriptPromise::EntryJavascriptPromiseAsyncSpawnCallStepExecutorFunction(RecyclableObject* function, CallInfo callInfo, ...)
	{
		PROBE_STACK(function->GetScriptContext(), Js::Constants::MinStackDefault);
		ARGUMENTS(args, callInfo);

		ScriptContext* scriptContext = function->GetScriptContext();
		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var undefinedVar = library->GetUndefined();

		Var argument = undefinedVar;

		if (args.Info.Count > 1)
		{
			argument = args[1];
		}

		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* asyncSpawnStepExecutorFunction = JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::FromVar(function);
		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* functionArg;
		JavascriptGenerator* gen = asyncSpawnStepExecutorFunction->GetGenerator();
		JavascriptFunction* reject = asyncSpawnStepExecutorFunction->GetReject();
		JavascriptFunction* resolve = asyncSpawnStepExecutorFunction->GetResolve();

		if (asyncSpawnStepExecutorFunction->GetIsReject())
		{
			functionArg = library->CreatePromiseAsyncSpawnStepArgumentExecutorFunction(EntryJavascriptPromiseAsyncSpawnStepThrowExecutorFunction, gen, argument, NULL, NULL, false);
		}
		else
		{
			functionArg = library->CreatePromiseAsyncSpawnStepArgumentExecutorFunction(EntryJavascriptPromiseAsyncSpawnStepNextExecutorFunction, gen, argument, NULL, NULL, false);
		}

		AsyncSpawnStep(functionArg, gen, resolve, reject);

		return undefinedVar;
	}

	void JavascriptPromise::AsyncSpawnStep(JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* nextFunction, JavascriptGenerator* gen, JavascriptFunction* resolve, JavascriptFunction* reject)
	{
		ScriptContext* scriptContext = resolve->GetScriptContext();
		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var undefinedVar = library->GetUndefined();

		JavascriptExceptionObject* exception = nullptr;
		Var value = nullptr;
		RecyclableObject* next = nullptr;
		bool done;

		try
		{
			next = RecyclableObject::FromVar(nextFunction->GetEntryPoint()(nextFunction, CallInfo(CallFlags_Value, 1), undefinedVar));
		}
		catch (JavascriptExceptionObject* e)
		{
			exception = e;
		}

		if (exception != nullptr)
		{
			// finished with failure, reject the promise
			TryRejectWithExceptionObject(exception, reject, scriptContext);
			return;
		}

		Assert(next != nullptr);
		done = JavascriptConversion::ToBool(JavascriptOperators::GetProperty(next, PropertyIds::done, scriptContext), scriptContext);
		if (done)
		{
			// finished with success, resolve the promise
			value = JavascriptOperators::GetProperty(next, PropertyIds::value, scriptContext);
			resolve->GetEntryPoint()(resolve, CallInfo(CallFlags_Value, 2), undefinedVar, value);
			return;
		}

		// not finished, chain off the yielded promise and `step` again
		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* successFunction = library->CreatePromiseAsyncSpawnStepArgumentExecutorFunction(EntryJavascriptPromiseAsyncSpawnCallStepExecutorFunction, gen, undefinedVar, resolve, reject);
		JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* failFunction = library->CreatePromiseAsyncSpawnStepArgumentExecutorFunction(EntryJavascriptPromiseAsyncSpawnCallStepExecutorFunction, gen, undefinedVar, resolve, reject, true);

		JavascriptFunction* promiseResolve = library->EnsurePromiseResolveFunction();
		value = JavascriptOperators::GetProperty(next, PropertyIds::value, scriptContext);
		JavascriptPromise* promise = FromVar(promiseResolve->GetEntryPoint()(promiseResolve, CallInfo(CallFlags_Value, 2), library->GetPromiseConstructor(), value));

		JavascriptFunction* promiseThen = JavascriptFunction::FromVar(JavascriptOperators::GetProperty(promise, PropertyIds::then, scriptContext));
		promiseThen->GetEntryPoint()(promiseThen, CallInfo(CallFlags_Value, 2), promise, successFunction);

		JavascriptFunction* promiseCatch = JavascriptFunction::FromVar(JavascriptOperators::GetProperty(promise, PropertyIds::catch_, scriptContext));
		promiseCatch->GetEntryPoint()(promiseCatch, CallInfo(CallFlags_Value, 2), promise, failFunction);
	}

	// NewPromiseCapability as described in ES6.0 (draft 29) Section 25.4.1.6
	JavascriptPromiseCapability* JavascriptPromise::NewPromiseCapability(Var constructor, ScriptContext* scriptContext)
	{
		if (!JavascriptOperators::IsConstructor(constructor))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction);
		}

		RecyclableObject* constructorFunc = RecyclableObject::FromVar(constructor);

		return CreatePromiseCapabilityRecord(constructorFunc, scriptContext);
	}

	// CreatePromiseCapabilityRecord as described in ES6.0 (draft 29) Section 25.4.1.6.1
	JavascriptPromiseCapability* JavascriptPromise::CreatePromiseCapabilityRecord(RecyclableObject* constructor, ScriptContext* scriptContext)
	{
		JavascriptLibrary* library = scriptContext->GetLibrary();
		Var undefinedVar = library->GetUndefined();
		JavascriptPromiseCapability* promiseCapability = JavascriptPromiseCapability::New(undefinedVar, undefinedVar, undefinedVar, scriptContext);

		JavascriptPromiseCapabilitiesExecutorFunction* executor = library->CreatePromiseCapabilitiesExecutorFunction(EntryCapabilitiesExecutorFunction, promiseCapability);

		CallInfo callinfo = Js::CallInfo((Js::CallFlags)(Js::CallFlags::CallFlags_Value | Js::CallFlags::CallFlags_New), 2);
		Var argVars[] = { constructor, executor };
		Arguments args(callinfo, argVars);
		Var promise = JavascriptFunction::CallAsConstructor(constructor, nullptr, args, scriptContext);

		if (!JavascriptConversion::IsCallable(promiseCapability->GetResolve()) || !JavascriptConversion::IsCallable(promiseCapability->GetReject()))
		{
			JavascriptError::ThrowTypeError(scriptContext, JSERR_NeedFunction, _u("Promise"));
		}

		promiseCapability->SetPromise(promise);

		return promiseCapability;
	}

	// TriggerPromiseReactions as defined in ES 2015 Section 25.4.1.7
	Var JavascriptPromise::TriggerPromiseReactions(JavascriptPromiseReactionList* reactions, Var resolution, ScriptContext* scriptContext)
	{
		JavascriptLibrary* library = scriptContext->GetLibrary();

		if (reactions != nullptr)
		{
			for (int i = 0; i < reactions->Count(); i++)
			{
				JavascriptPromiseReaction* reaction = reactions->Item(i);

				EnqueuePromiseReactionTask(reaction, resolution, scriptContext);
			}
		}

		return library->GetUndefined();
	}

	void JavascriptPromise::EnqueuePromiseReactionTask(JavascriptPromiseReaction* reaction, Var resolution, ScriptContext* scriptContext)
	{
		Assert(resolution != nullptr);

		JavascriptLibrary* library = scriptContext->GetLibrary();
		JavascriptPromiseReactionTaskFunction* reactionTaskFunction = library->CreatePromiseReactionTaskFunction(EntryReactionTaskFunction, reaction, resolution);

		library->EnqueueTask(reactionTaskFunction);
	}

	JavascriptPromiseResolveOrRejectFunction::JavascriptPromiseResolveOrRejectFunction(DynamicType* type)
		: RuntimeFunction(type, &Js::JavascriptPromise::EntryInfo::ResolveOrRejectFunction), promise(nullptr), isReject(false), alreadyResolvedWrapper(nullptr)
	{ }

	JavascriptPromiseResolveOrRejectFunction::JavascriptPromiseResolveOrRejectFunction(DynamicType* type, FunctionInfo* functionInfo, JavascriptPromise* promise, bool isReject, JavascriptPromiseResolveOrRejectFunctionAlreadyResolvedWrapper* alreadyResolvedRecord)
		: RuntimeFunction(type, functionInfo), promise(promise), isReject(isReject), alreadyResolvedWrapper(alreadyResolvedRecord)
	{ }

	bool JavascriptPromiseResolveOrRejectFunction::Is(Var var)
	{
		if (JavascriptFunction::Is(var))
		{
			JavascriptFunction* obj = JavascriptFunction::FromVar(var);

			return VirtualTableInfo<JavascriptPromiseResolveOrRejectFunction>::HasVirtualTable(obj)
				|| VirtualTableInfo<CrossSiteObject<JavascriptPromiseResolveOrRejectFunction>>::HasVirtualTable(obj);
		}

		return false;
	}

	JavascriptPromiseResolveOrRejectFunction* JavascriptPromiseResolveOrRejectFunction::FromVar(Var var)
	{
		Assert(JavascriptPromiseResolveOrRejectFunction::Is(var));

		return static_cast<JavascriptPromiseResolveOrRejectFunction*>(var);
	}

	JavascriptPromise* JavascriptPromiseResolveOrRejectFunction::GetPromise()
	{
		return this->promise;
	}

	bool JavascriptPromiseResolveOrRejectFunction::IsRejectFunction()
	{
		return this->isReject;
	}

	bool JavascriptPromiseResolveOrRejectFunction::IsAlreadyResolved()
	{
		Assert(this->alreadyResolvedWrapper);

		return this->alreadyResolvedWrapper->alreadyResolved;
	}

	void JavascriptPromiseResolveOrRejectFunction::SetAlreadyResolved(bool is)
	{
		Assert(this->alreadyResolvedWrapper);

		this->alreadyResolvedWrapper->alreadyResolved = is;
	}

	JavascriptPromiseAsyncSpawnExecutorFunction::JavascriptPromiseAsyncSpawnExecutorFunction(DynamicType* type, FunctionInfo* functionInfo, JavascriptGenerator* generatorFunction, Var target)
		: RuntimeFunction(type, functionInfo), generatorFunction(generatorFunction), target(target)
	{ }

	bool JavascriptPromiseAsyncSpawnExecutorFunction::Is(Var var)
	{
		if (JavascriptFunction::Is(var))
		{
			JavascriptFunction* obj = JavascriptFunction::FromVar(var);

			return VirtualTableInfo<JavascriptPromiseAsyncSpawnExecutorFunction>::HasVirtualTable(obj)
				|| VirtualTableInfo<CrossSiteObject<JavascriptPromiseAsyncSpawnExecutorFunction>>::HasVirtualTable(obj);
		}

		return false;
	}

	JavascriptPromiseAsyncSpawnExecutorFunction* JavascriptPromiseAsyncSpawnExecutorFunction::FromVar(Var var)
	{
		Assert(JavascriptPromiseAsyncSpawnExecutorFunction::Is(var));

		return static_cast<JavascriptPromiseAsyncSpawnExecutorFunction*>(var);
	}

	JavascriptGenerator* JavascriptPromiseAsyncSpawnExecutorFunction::GetGeneratorFunction()
	{
		return this->generatorFunction;
	}

	Var JavascriptPromiseAsyncSpawnExecutorFunction::GetTarget()
	{
		return this->target;
	}

	JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction(DynamicType* type, FunctionInfo* functionInfo, JavascriptGenerator* generator, Var argument, JavascriptFunction* resolve, JavascriptFunction* reject, bool isReject)
		: RuntimeFunction(type, functionInfo), generator(generator), argument(argument), resolve(resolve), reject(reject), isReject(isReject)
	{ }

	bool JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::Is(Var var)
	{
		if (JavascriptFunction::Is(var))
		{
			JavascriptFunction* obj = JavascriptFunction::FromVar(var);

			return VirtualTableInfo<JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction>::HasVirtualTable(obj)
				|| VirtualTableInfo<CrossSiteObject<JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction>>::HasVirtualTable(obj);
		}

		return false;
	}

	JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction* JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::FromVar(Var var)
	{
		Assert(JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::Is(var));

		return static_cast<JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction*>(var);
	}

	JavascriptGenerator* JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::GetGenerator()
	{
		return this->generator;
	}

	JavascriptFunction* JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::GetResolve()
	{
		return this->resolve;
	}

	JavascriptFunction* JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::GetReject()
	{
		return this->reject;
	}

	bool JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::GetIsReject()
	{
		return this->isReject;
	}

	Var JavascriptPromiseAsyncSpawnStepArgumentExecutorFunction::GetArgument()
	{
		return this->argument;
	}

	JavascriptPromiseCapabilitiesExecutorFunction::JavascriptPromiseCapabilitiesExecutorFunction(DynamicType* type, FunctionInfo* functionInfo, JavascriptPromiseCapability* capability)
		: RuntimeFunction(type, functionInfo), capability(capability)
	{ }

	bool JavascriptPromiseCapabilitiesExecutorFunction::Is(Var var)
	{
		if (JavascriptFunction::Is(var))
		{
			JavascriptFunction* obj = JavascriptFunction::FromVar(var);

			return VirtualTableInfo<JavascriptPromiseCapabilitiesExecutorFunction>::HasVirtualTable(obj)
				|| VirtualTableInfo<CrossSiteObject<JavascriptPromiseCapabilitiesExecutorFunction>>::HasVirtualTable(obj);
		}

		return false;
	}

	JavascriptPromiseCapabilitiesExecutorFunction* JavascriptPromiseCapabilitiesExecutorFunction::FromVar(Var var)
	{
		Assert(JavascriptPromiseCapabilitiesExecutorFunction::Is(var));

		return static_cast<JavascriptPromiseCapabilitiesExecutorFunction*>(var);
	}

	JavascriptPromiseCapability* JavascriptPromiseCapabilitiesExecutorFunction::GetCapability()
	{
		return this->capability;
	}

	JavascriptPromiseCapability* JavascriptPromiseCapability::New(Var promise, Var resolve, Var reject, ScriptContext* scriptContext)
	{
		return RecyclerNew(scriptContext->GetRecycler(), JavascriptPromiseCapability, promise, resolve, reject);
	}

	Var JavascriptPromiseCapability::GetResolve()
	{
		return this->resolve;
	}

	Var JavascriptPromiseCapability::GetReject()
	{
		return this->reject;
	}

	Var JavascriptPromiseCapability::GetPromise()
	{
		return this->promise;
	}

	void JavascriptPromiseCapability::SetPromise(Var promise)
	{
		this->promise = promise;
	}

	void JavascriptPromiseCapability::SetResolve(Var resolve)
	{
		this->resolve = resolve;
	}

	void JavascriptPromiseCapability::SetReject(Var reject)
	{
		this->reject = reject;
	}

	JavascriptPromiseReaction* JavascriptPromiseReaction::New(JavascriptPromiseCapability* capabilities, RecyclableObject* handler, ScriptContext* scriptContext)
	{
		return RecyclerNew(scriptContext->GetRecycler(), JavascriptPromiseReaction, capabilities, handler);
	}

	JavascriptPromiseCapability* JavascriptPromiseReaction::GetCapabilities()
	{
		return this->capabilities;
	}

	RecyclableObject* JavascriptPromiseReaction::GetHandler()
	{
		return this->handler;
	}

	JavascriptPromiseReaction* JavascriptPromiseReactionTaskFunction::GetReaction()
	{
		return this->reaction;
	}

	Var JavascriptPromiseReactionTaskFunction::GetArgument()
	{
		return this->argument;
	}

	JavascriptPromise* JavascriptPromiseResolveThenableTaskFunction::GetPromise()
	{
		return this->promise;
	}

	RecyclableObject* JavascriptPromiseResolveThenableTaskFunction::GetThenable()
	{
		return this->thenable;
	}

	RecyclableObject* JavascriptPromiseResolveThenableTaskFunction::GetThenFunction()
	{
		return this->thenFunction;
	}

	JavascriptPromiseAllResolveElementFunction::JavascriptPromiseAllResolveElementFunction(DynamicType* type)
		: RuntimeFunction(type, &Js::JavascriptPromise::EntryInfo::AllResolveElementFunction), index(0), values(nullptr), capabilities(nullptr), remainingElementsWrapper(nullptr), alreadyCalled(false)
	{ }

	JavascriptPromiseAllResolveElementFunction::JavascriptPromiseAllResolveElementFunction(DynamicType* type, FunctionInfo* functionInfo, uint32 index, JavascriptArray* values, JavascriptPromiseCapability* capabilities, JavascriptPromiseAllResolveElementFunctionRemainingElementsWrapper* remainingElementsWrapper)
		: RuntimeFunction(type, functionInfo), index(index), values(values), capabilities(capabilities), remainingElementsWrapper(remainingElementsWrapper), alreadyCalled(false)
	{ }

	bool JavascriptPromiseAllResolveElementFunction::Is(Var var)
	{
		if (JavascriptFunction::Is(var))
		{
			JavascriptFunction* obj = JavascriptFunction::FromVar(var);

			return VirtualTableInfo<JavascriptPromiseAllResolveElementFunction>::HasVirtualTable(obj)
				|| VirtualTableInfo<CrossSiteObject<JavascriptPromiseAllResolveElementFunction>>::HasVirtualTable(obj);
		}

		return false;
	}

	JavascriptPromiseAllResolveElementFunction* JavascriptPromiseAllResolveElementFunction::FromVar(Var var)
	{
		Assert(JavascriptPromiseAllResolveElementFunction::Is(var));

		return static_cast<JavascriptPromiseAllResolveElementFunction*>(var);
	}

	JavascriptPromiseCapability* JavascriptPromiseAllResolveElementFunction::GetCapabilities()
	{
		return this->capabilities;
	}

	uint32 JavascriptPromiseAllResolveElementFunction::GetIndex()
	{
		return this->index;
	}

	uint32 JavascriptPromiseAllResolveElementFunction::GetRemainingElements()
	{
		return this->remainingElementsWrapper->remainingElements;
	}

	JavascriptArray* JavascriptPromiseAllResolveElementFunction::GetValues()
	{
		return this->values;
	}

	uint32 JavascriptPromiseAllResolveElementFunction::DecrementRemainingElements()
	{
		return --(this->remainingElementsWrapper->remainingElements);
	}

	bool JavascriptPromiseAllResolveElementFunction::IsAlreadyCalled() const
	{
		return this->alreadyCalled;
	}

	void JavascriptPromiseAllResolveElementFunction::SetAlreadyCalled(const bool is)
	{
		this->alreadyCalled = is;
	}

	Var JavascriptPromise::EntryGetterSymbolSpecies(RecyclableObject* function, CallInfo callInfo, ...)
	{
		ARGUMENTS(args, callInfo);

		Assert(args.Info.Count > 0);

		return args[0];
	}
} // namespace Js
